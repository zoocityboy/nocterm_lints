// Copyright (c) 2022, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/ast.dart';
import '../utilities/extensions/nocterm.dart';
import '../utilities/extensions/session_helper.dart';

class ConvertToStatelessWidget extends ResolvedCorrectionProducer {
  ConvertToStatelessWidget({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind =>
      DartAssistKind.noctermConvertToStatelessComponent;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final componentClass = node.thisOrAncestorOfType<ClassDeclaration>();
    final superclass = componentClass?.extendsClause?.superclass;
    if (componentClass == null || superclass == null) return;

    final componentClassBody = componentClass.body;
    if (componentClassBody is! BlockClassBody) {
      return;
    }

    // Don't spam, activate only from the `class` keyword to the class body.
    if (selectionOffset < componentClass.classKeyword.offset ||
        selectionOffset > componentClassBody.leftBracket.end) {
      return;
    }

    // Must be a StatefulWidget subclass.
    final widgetClassFragment = componentClass.declaredFragment!;
    final widgetClassElement = widgetClassFragment.element;
    final superType = widgetClassElement.supertype;
    if (superType == null || !superType.isExactlyStatefulComponentType) {
      return;
    }

    final createStateMethod = _findCreateStateMethod(componentClass);
    if (createStateMethod == null) return;

    final stateClass = _findStateClass(widgetClassElement);
    final stateClassElement = stateClass?.declaredFragment!.element;
    if (stateClass == null ||
        stateClassElement == null ||
        !Identifier.isPrivateName(stateClass.namePart.typeName.lexeme) ||
        !_isSameTypeParameters(componentClass, stateClass)) {
      return;
    }

    final verifier = _StatelessVerifier();
    final fieldFinder = _FieldFinder();

    for (final member in stateClass.members2) {
      if (member is ConstructorDeclaration) {
        member.accept(fieldFinder);
      } else if (member is MethodDeclaration) {
        member.accept(verifier);
        if (!verifier.canBeStateless) {
          return;
        }
      }
    }

    final usageVerifier = _StateUsageVisitor(
      widgetClassElement,
      stateClassElement,
    );
    unit.visitChildren(usageVerifier);
    if (usageVerifier.used) return;

    final fieldsAssignedInConstructors =
        fieldFinder.fieldsAssignedInConstructors;

    // Prepare nodes to move.
    final nodesToMove = <ClassMember>[];
    final elementsToMove = <Element>{};
    for (final member in stateClass.members2) {
      if (member is FieldDeclaration) {
        if (member.isStatic) {
          return;
        }
        for (final fieldNode in member.fields.variables) {
          final fieldElement =
              fieldNode.declaredFragment!.element as FieldElement;
          if (!fieldsAssignedInConstructors.contains(fieldElement)) {
            nodesToMove.add(member);
            elementsToMove.add(fieldElement);

            final getter = fieldElement.getter;
            if (getter != null) {
              elementsToMove.add(getter);
            }

            final setter = fieldElement.setter;
            if (setter != null) {
              elementsToMove.add(setter);
            }
          }
        }
      } else if (member is MethodDeclaration) {
        if (member.isStatic) {
          return;
        }
        if (!_isDefaultOverride(member)) {
          nodesToMove.add(member);
          elementsToMove.add(member.declaredFragment!.element);
        }
      }
    }

    /// Return the code for the [movedNode], so that qualification of the
    /// references to the widget (`widget.` or static `MyWidgetClass.`)
    /// is removed
    String rewriteWidgetMemberReferences(AstNode movedNode) {
      final linesRange = utils.getLinesRange(range.node(movedNode));
      final text = utils.getRangeText(linesRange);

      // Remove `widget.` before references to the widget instance members.
      final visitor = _ReplacementEditBuilder(
        widgetClassElement,
        elementsToMove,
        linesRange,
      );
      movedNode.accept(visitor);
      return SourceEdit.applySequence(text, visitor.edits.reversed.toList());
    }

    final statelessComponentClass = await getNoctermClass(
      sessionHelper,
      'StatelessComponent',
    );
    if (statelessComponentClass == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(superclass), (builder) {
        builder.writeReference(statelessComponentClass);
      });

      builder.addDeletion(range.deletionRange(stateClass));

      var createStateNextToEnd = createStateMethod.endToken.next!;
      createStateNextToEnd =
          createStateNextToEnd.precedingComments ?? createStateNextToEnd;
      final createStateRange = range.startOffsetEndOffset(
        utils.getLineContentStart(createStateMethod.offset),
        utils.getLineContentStart(createStateNextToEnd.offset),
      );

      final newLine =
          createStateNextToEnd.type != TokenType.CLOSE_CURLY_BRACKET;

      builder.addReplacement(createStateRange, (builder) {
        for (var i = 0; i < nodesToMove.length; i++) {
          final member = nodesToMove[i];
          final comments = member.beginToken.precedingComments;
          if (comments != null) {
            final offset = utils.getLineContentStart(comments.offset);
            final length = comments.end - offset;
            builder.writeln(utils.getText(offset, length));
          }

          final text = rewriteWidgetMemberReferences(member);
          builder.write(text);
          if (newLine || i < nodesToMove.length - 1) {
            builder.writeln();
          }
        }
      });
    });
  }

  MethodDeclaration? _findCreateStateMethod(ClassDeclaration widgetClass) {
    for (final member in widgetClass.members2) {
      if (member is MethodDeclaration && member.name.lexeme == 'createState') {
        final parameters = member.parameters;
        if (parameters?.parameters.isEmpty ?? false) {
          return member;
        }
        break;
      }
    }
    return null;
  }

  ClassDeclaration? _findStateClass(ClassElement widgetClassElement) {
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final type = declaration.extendsClause?.superclass.type;

        if (_isState(widgetClassElement, type)) {
          return declaration;
        }
      }
    }
    return null;
  }

  bool _isSameTypeParameters(
    ClassDeclaration widgetClass,
    ClassDeclaration stateClass,
  ) {
    List<TypeParameter>? parameters(ClassDeclaration declaration) =>
        declaration.namePart.typeParameters?.typeParameters;

    final widgetParams = parameters(widgetClass);
    final stateParams = parameters(stateClass);

    if (widgetParams == null && stateParams == null) {
      return true;
    }
    if (widgetParams == null || stateParams == null) {
      return false;
    }
    if (widgetParams.length < stateParams.length) {
      return false;
    }
    outer:
    for (final stateParam in stateParams) {
      for (final widgetParam in widgetParams) {
        if (stateParam.name.lexeme == widgetParam.name.lexeme &&
            stateParam.bound?.type == widgetParam.bound?.type) {
          continue outer;
        }
      }
      return false;
    }
    return true;
  }

  static bool _isDefaultOverride(MethodDeclaration? methodDeclaration) {
    final body = methodDeclaration?.body;
    if (body != null) {
      Expression expression;
      if (body is BlockFunctionBody) {
        final statements = body.block.statements;
        if (statements.isEmpty) return true;
        if (statements.length > 1) return false;
        final first = statements.first;
        if (first is! ExpressionStatement) return false;
        expression = first.expression;
      } else if (body is ExpressionFunctionBody) {
        expression = body.expression;
      } else {
        return false;
      }
      if (expression is MethodInvocation &&
          expression.target is SuperExpression &&
          methodDeclaration!.name.lexeme == expression.methodName.name) {
        return true;
      }
    }
    return false;
  }

  static bool _isState(ClassElement widgetClassElement, DartType? type) {
    if (type is! InterfaceType) return false;

    final firstArgument = type.typeArguments.singleOrNull;
    if (firstArgument is! InterfaceType ||
        firstArgument.element != widgetClassElement) {
      return false;
    }

    final classElement = type.element;
    return classElement is ClassElement && classElement.isExactState;
  }
}

class _FieldFinder extends RecursiveAstVisitor<void> {
  Set<FieldElement> fieldsAssignedInConstructors = {};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.parent is FieldFormalParameter) {
      final element = node.element;
      if (element is FieldFormalParameterElement) {
        final field = element.field;
        if (field != null) {
          fieldsAssignedInConstructors.add(field);
        }
      }
    }
    if (node.parent is ConstructorFieldInitializer) {
      final element = node.element;
      if (element is FieldElement) {
        fieldsAssignedInConstructors.add(element);
      }
    }
    if (node.inSetterContext()) {
      final element = node.writeOrReadElement;
      final field = switch (element) {
        PropertyAccessorElement(:final variable) => variable,
        _ => null,
      };
      if (field is FieldElement) {
        fieldsAssignedInConstructors.add(field);
      }
    }
  }
}

class _ReplacementEditBuilder extends RecursiveAstVisitor<void> {
  _ReplacementEditBuilder(
    this.widgetClassElement,
    this.elementsToMove,
    this.linesRange,
  );
  final ClassElement widgetClassElement;

  final Set<Element> elementsToMove;

  final SourceRange linesRange;

  List<SourceEdit> edits = [];

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.inDeclarationContext()) {
      return;
    }
    final element = node.element;
    if (element is ExecutableElement &&
        element.enclosingElement == widgetClassElement &&
        !elementsToMove.contains(element)) {
      final parent = node.parent;
      if (parent is PrefixedIdentifier) {
        final grandParent = parent.parent;
        SourceEdit? rightBracketEdit;
        if (!node.name.contains(r'$') &&
            grandParent is InterpolationExpression &&
            grandParent.leftBracket.type ==
                TokenType.STRING_INTERPOLATION_EXPRESSION) {
          edits.add(
            SourceEdit(
              grandParent.leftBracket.end - 1 - linesRange.offset,
              1,
              '',
            ),
          );
          final offset = grandParent.rightBracket?.offset;
          if (offset != null) {
            rightBracketEdit = SourceEdit(offset - linesRange.offset, 1, '');
          }
        }
        final offset = parent.prefix.offset;
        final length = parent.period.end - offset;
        edits.add(SourceEdit(offset - linesRange.offset, length, ''));
        if (rightBracketEdit != null) {
          edits.add(rightBracketEdit);
        }
      } else if (parent is MethodInvocation) {
        final target = parent.target;
        final operator = parent.operator;
        if (target != null && operator != null) {
          final offset = target.offset;
          final length = operator.end - offset;
          edits.add(SourceEdit(offset - linesRange.offset, length, ''));
        }
      } else if (parent is PropertyAccess) {
        final target = parent.target;
        final operator = parent.operator;
        if (target != null) {
          final offset = target.offset;
          final length = operator.end - offset;
          edits.add(SourceEdit(offset - linesRange.offset, length, ''));
        }
      }
    }
  }
}

class _StatelessVerifier extends RecursiveAstVisitor<void> {
  bool canBeStateless = true;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodElement = node.methodName.element?.baseElement;
    final classElement = methodElement?.enclosingElement;
    if (classElement is ClassElement &&
        classElement.isExactState &&
        !ConvertToStatelessWidget._isDefaultOverride(
          node.thisOrAncestorOfType<MethodDeclaration>(),
        )) {
      canBeStateless = false;
      return;
    }
    super.visitMethodInvocation(node);
  }
}

class _StateUsageVisitor extends RecursiveAstVisitor<void> {
  _StateUsageVisitor(this.widgetClassElement, this.stateClassElement);
  bool used = false;
  ClassElement widgetClassElement;
  ClassElement stateClassElement;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    final type = node.staticType;
    if (type is! InterfaceType || type.element != stateClassElement) {
      return;
    }
    final methodDeclaration = node.thisOrAncestorOfType<MethodDeclaration>();
    final classDeclaration = methodDeclaration
        ?.thisOrAncestorOfType<ClassDeclaration>();

    if (methodDeclaration?.name.lexeme != 'createState' ||
        classDeclaration?.declaredFragment!.element != widgetClassElement) {
      used = true;
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final type = node.staticType;
    if (type is InterfaceType &&
        node.methodName.name == 'createState' &&
        (ConvertToStatelessWidget._isState(widgetClassElement, type) ||
            type.element == stateClassElement)) {
      used = true;
    }
  }
}
