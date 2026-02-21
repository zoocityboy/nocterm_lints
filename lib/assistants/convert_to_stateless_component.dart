// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.

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
import '../utilities/extensions/logging_extensions.dart';
import '../utilities/extensions/nocterm.dart';
import '../utilities/extensions/session_helper.dart';

class ConvertToStatelessComponent extends ResolvedCorrectionProducer {
  ConvertToStatelessComponent({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind =>
      DartAssistKind.noctermConvertToStatelessComponent;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    try {
      logInfo('Starting assist: Convert to StatelessComponent');
      final componentClass = node.thisOrAncestorOfType<ClassDeclaration>();
      final superclass = componentClass?.extendsClause?.superclass;
      logInfo(
        'Found component class: ${componentClass?.namePart.typeName.lexeme}, '
        'superclass: ${superclass?.name.lexeme}',
      );
      if (componentClass == null || superclass == null) {
        logError(
          ' No class declaration or superclass found at offset $selectionOffset',
        );
        return;
      }
      late final componentClassBody = componentClass.body;
      try {
        if (componentClassBody is! BlockClassBody) {
          logError(' Component class body is not a block');
          return;
        }
      } catch (e, s) {
        logError(
          'Failed to analyze class body at offset $selectionOffset',
          e,
          s,
        );
        return;
      }

      // Don't spam, activate only from the `class` keyword to the class body.
      if (selectionOffset < componentClass.classKeyword.offset ||
          selectionOffset > componentClassBody.rightBracket.end) {
        logError(
          ' Selection is outside the component class body',
        );
        return;
      }

      // Must be a StatefulComponent subclass.
      final componentClassFragment = componentClass.declaredFragment!;
      final componentClassElement = componentClassFragment.element;
      final superType = componentClassElement.supertype;
      if (superType == null || !superType.isExactlyStatefulComponentType) {
        logError(
          ' Component class is not a StatefulComponent subclass',
        );
        return;
      }

      final createStateMethod = _findCreateStateMethod(componentClass);
      if (createStateMethod == null) return;

      final stateClass = _findStateClass(componentClassElement);
      final stateClassElement = stateClass?.declaredFragment!.element;
      if (stateClass == null ||
          stateClassElement == null ||
          !Identifier.isPrivateName(stateClass.namePart.typeName.lexeme) ||
          !_isSameTypeParameters(componentClass, stateClass)) {
        logError(' State class is not valid');
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
            logError(
              ' State class cannot be converted to StatelessComponent',
            );
            return;
          }
        }
      }

      final usageVerifier = _StateUsageVisitor(
        componentClassElement,
        stateClassElement,
      );
      unit.visitChildren(usageVerifier);
      if (usageVerifier.used) {
        logError(
          ' State class is used in a way that prevents'
          ' conversion to StatelessComponent',
        );
        return;
      }

      final fieldsAssignedInConstructors =
          fieldFinder.fieldsAssignedInConstructors;

      // Prepare nodes to move.
      final nodesToMove = <ClassMember>[];
      final elementsToMove = <Element>{};
      for (final member in stateClass.members2) {
        if (member is FieldDeclaration) {
          if (member.isStatic) {
            logWarning(
              ' Static members cannot be moved to StatelessComponent '
              ' and will be skipped: '
              '${member.fields.variables.map((v) => v.name.lexeme).join(', ')}',
            );
            continue;
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
            logWarning(
              ' Static members cannot be moved to StatelessComponent and will'
              ' be skipped: ${member.name.lexeme}',
            );
            continue;
          }
          if (!_isDefaultOverride(member)) {
            nodesToMove.add(member);
            elementsToMove.add(member.declaredFragment!.element);
          }
        }
      }

      /// Return the code for the [movedNode], so that qualification of the
      /// references to the component (`component.` or static `MyComponentClass.`)
      /// is removed
      String rewriteComponentMemberReferences(AstNode movedNode) {
        final linesRange = utils.getLinesRange(range.node(movedNode));
        final text = utils.getRangeText(linesRange);

        // Remove `component.` before references to the component instance members.
        final visitor = _ReplacementEditBuilder(
          componentClassElement,
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
        logError(' Could not find StatelessComponent class');
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

            final text = rewriteComponentMemberReferences(member);
            builder.write(text);
            if (newLine || i < nodesToMove.length - 1) {
              builder.writeln();
            }
          }
        });
      });
    } catch (e, st) {
      logError('Exception during assist computation: $e\n$st');
    }
  }

  MethodDeclaration? _findCreateStateMethod(ClassDeclaration componentClass) {
    for (final member in componentClass.members2) {
      if (member is MethodDeclaration && member.name.lexeme == 'createState') {
        final parameters = member.parameters;
        if (parameters?.parameters.isEmpty ?? false) {
          return member;
        }
        break;
      }
    }
    logError(' Could not find createState method');
    return null;
  }

  ClassDeclaration? _findStateClass(ClassElement componentClassElement) {
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final type = declaration.extendsClause?.superclass.type;

        if (_isState(componentClassElement, type)) {
          return declaration;
        }
      }
    }
    logError(' Could not find State class');
    return null;
  }

  bool _isSameTypeParameters(
    ClassDeclaration componentClass,
    ClassDeclaration stateClass,
  ) {
    List<TypeParameter>? parameters(ClassDeclaration declaration) =>
        declaration.namePart.typeParameters?.typeParameters;

    final widgetParams = parameters(componentClass);
    final stateParams = parameters(stateClass);

    if (widgetParams == null && stateParams == null) {
      logInfo('Both component and state classes have no type parameters');
      return true;
    }
    if (widgetParams == null || stateParams == null) {
      logError(
        'Mismatch in type parameters between component and state classes',
      );
      return false;
    }
    if (widgetParams.length < stateParams.length) {
      logError(
        'State class has more type parameters than widget class, '
        'which is not supported',
      );
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
      logError('Type parameters do not match between widget and state classes');
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

  static bool _isState(ClassElement componentClassElement, DartType? type) {
    if (type is! InterfaceType) return false;

    final firstArgument = type.typeArguments.singleOrNull;
    if (firstArgument is! InterfaceType ||
        firstArgument.element != componentClassElement) {
      return false;
    }

    final classElement = type.element;
    return classElement is ClassElement && classElement.isExactState;
  }
}

class _FieldFinder extends RecursiveAstVisitor<void> {
  Set<FieldElement> fieldsAssignedInConstructors = {};

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    final element = node.declaredFragment?.element;
    if (element is FieldFormalParameterElement) {
      final field = element.field;
      if (field != null) {
        fieldsAssignedInConstructors.add(field);
      }
    }
    super.visitFieldFormalParameter(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.parent is ConstructorFieldInitializer) {
      final element = node.element;
      if (element is FieldElement) {
        fieldsAssignedInConstructors.add(element);
      }
    }
    if (node.inSetterContext()) {
      final element = node.writeOrReadElement;
      if (element is SetterElement) {
        final field = element.variable;
        if (field is FieldElement) {
          fieldsAssignedInConstructors.add(field);
        }
      }
    }
  }
}

class _ReplacementEditBuilder extends RecursiveAstVisitor<void> {
  _ReplacementEditBuilder(
    this.componentClassElement,
    this.elementsToMove,
    this.linesRange,
  );
  final ClassElement componentClassElement;

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
        element.enclosingElement == componentClassElement &&
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
        !ConvertToStatelessComponent._isDefaultOverride(
          node.thisOrAncestorOfType<MethodDeclaration>(),
        )) {
      canBeStateless = false;
      return;
    }
    super.visitMethodInvocation(node);
  }
}

class _StateUsageVisitor extends RecursiveAstVisitor<void> {
  _StateUsageVisitor(this.componentClassElement, this.stateClassElement);
  bool used = false;
  ClassElement componentClassElement;
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
        classDeclaration?.declaredFragment?.element != componentClassElement) {
      used = true;
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final type = node.staticType;
    if (type is InterfaceType &&
        node.methodName.name == 'createState' &&
        (ConvertToStatelessComponent._isState(componentClassElement, type) ||
            type.element == stateClassElement)) {
      used = true;
    }
  }
}
