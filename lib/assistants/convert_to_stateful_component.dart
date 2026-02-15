// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
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

class ConvertToStatefulWidget extends ResolvedCorrectionProducer {
  ConvertToStatefulWidget({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermConvertToStatefulWidget;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final componentClass = node.thisOrAncestorOfType<ClassDeclaration>();
    final superclass = componentClass?.extendsClause?.superclass;
    if (componentClass == null || superclass == null) {
      return;
    }

    final body = componentClass.body;
    if (body is! BlockClassBody) {
      return;
    }

    // Don't spam, activate only from the `class` keyword to the class body.
    if (selectionOffset < componentClass.classKeyword.offset ||
        selectionOffset > body.leftBracket.end) {
      return;
    }

    // Must be a StatelessWidget subclass.
    final componentClassElement = componentClass.declaredFragment!.element;
    final superType = componentClassElement.supertype;
    if (superType == null || !superType.isExactlyStatelessComponentType) {
      return;
    }

    final buildMethod = _findBuildMethod(componentClass);
    if (buildMethod == null) {
      return;
    }

    final componentName = componentClassElement.displayName;
    final stateName = componentClassElement.isPrivate
        ? '${componentName}State'
        : '_${componentName}State';

    // Find fields assigned in constructors.
    final visitor = _FieldFinder();
    for (final member in body.members) {
      if (member is ConstructorDeclaration) {
        member.accept(visitor);
      }
    }
    final fieldsAssignedInConstructors = visitor.fieldsAssignedInConstructors;

    // Prepare nodes to move.
    final nodesToMove = <ClassMember>{};
    final elementsToMove = <Element>{};
    for (final member in body.members) {
      if (member is FieldDeclaration && !member.isStatic) {
        for (final fieldNode in member.fields.variables) {
          final fieldFragment = fieldNode.declaredFragment! as FieldFragment;
          final fieldElement = fieldFragment.element;
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
      } else if (member is MethodDeclaration && !member.isStatic) {
        nodesToMove.add(member);
        elementsToMove.add(member.declaredFragment!.element);
      }
    }

    /// Return the code for the [movedNode] which is suitable to be used
    /// inside the `State` class, so that references to the widget fields and
    /// methods, that are not moved, are qualified with the corresponding
    /// instance `widget.`, or static `MyWidgetClass.` qualifier.
    String rewriteWidgetMemberReferences(AstNode movedNode) {
      final linesRange = utils.getLinesRange(range.node(movedNode));
      final text = utils.getRangeText(linesRange);

      // Insert `widget.` before references to the widget instance members.
      final visitor = _ReplacementEditBuilder(
        componentClassElement,
        elementsToMove,
        linesRange,
      );
      movedNode.accept(visitor);
      return SourceEdit.applySequence(text, visitor.edits.reversed.toList());
    }

    final statefulComponentClass = await getNoctermClass(
      sessionHelper,
      'StatefulComponent',
    );
    final stateClass = await getNoctermClass(sessionHelper, 'State');
    if (statefulComponentClass == null || stateClass == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(superclass), (builder) {
        builder.writeReference(statefulComponentClass);
      });

      var replaceOffset = 0;
      var hasBuildMethod = false;

      var typeParams = '';
      final typeParameters = componentClass.namePart.typeParameters;
      if (typeParameters != null) {
        typeParams = utils.getNodeText(typeParameters);
      }

      /// Replace code between [replaceOffset] and [replaceEnd] with
      /// `createState()`, empty line, or nothing.
      void replaceInterval(
        int replaceEnd, {
        bool replaceWithEmptyLine = false,
        bool hasEmptyLineBeforeCreateState = false,
        bool hasEmptyLineAfterCreateState = true,
      }) {
        final replaceLength = replaceEnd - replaceOffset;
        builder.addReplacement(SourceRange(replaceOffset, replaceLength), (
          builder,
        ) {
          if (hasBuildMethod) {
            if (hasEmptyLineBeforeCreateState) {
              builder.writeln();
            }
            builder.writeln('  @override');
            builder.write('  ');
            builder.writeReference(stateClass);
            builder.write(
              '<${componentClass.namePart.typeName.lexeme}$typeParams>',
            );
            builder.writeln(' createState() => $stateName$typeParams();');
            if (hasEmptyLineAfterCreateState) {
              builder.writeln();
            }
            hasBuildMethod = false;
          } else if (replaceWithEmptyLine) {
            builder.writeln();
          }
        });
        replaceOffset = 0;
      }

      // Remove continuous ranges of lines of nodes being moved.
      var lastToRemoveIsField = false;
      var endOfLastNodeToKeep = 0;
      for (final node in body.members) {
        if (nodesToMove.contains(node)) {
          if (replaceOffset == 0) {
            final comments = node.beginToken.precedingComments;
            final start = comments ?? node;
            replaceOffset = utils.getLineContentStart(start.offset);
          }
          if (node == buildMethod) {
            hasBuildMethod = true;
          }
          lastToRemoveIsField = node is FieldDeclaration;
        } else {
          final linesRange = utils.getLinesRange(range.node(node));
          endOfLastNodeToKeep = linesRange.end;
          if (replaceOffset != 0) {
            replaceInterval(
              linesRange.offset,
              replaceWithEmptyLine:
                  lastToRemoveIsField && node is! FieldDeclaration,
            );
          }
        }
      }

      // Remove nodes at the end of the widget class.
      if (replaceOffset != 0) {
        // Remove from the last node to keep, so remove empty lines.
        if (endOfLastNodeToKeep != 0) {
          replaceOffset = endOfLastNodeToKeep;
        }
        replaceInterval(
          body.rightBracket.offset,
          hasEmptyLineBeforeCreateState: endOfLastNodeToKeep != 0,
          hasEmptyLineAfterCreateState: false,
        );
      }

      // Create the State subclass.
      builder.addInsertion(componentClass.end, (builder) {
        builder.writeln();
        builder.writeln();

        builder.write('class $stateName$typeParams extends ');
        builder.writeReference(stateClass);

        // Write just param names (and not bounds, metadata and docs).
        builder.write('<${componentClass.namePart.typeName.lexeme}');
        if (typeParameters != null) {
          builder.write('<');
          var first = true;
          for (final param in typeParameters.typeParameters) {
            if (!first) {
              builder.write(', ');
              first = false;
            }
            builder.write(param.name.lexeme);
          }
          builder.write('>');
        }

        builder.writeln('> {');

        var writeEmptyLine = false;
        for (final member in nodesToMove) {
          if (writeEmptyLine) {
            builder.writeln();
          }

          final comments = member.beginToken.precedingComments;
          if (comments != null) {
            final offset = utils.getLineContentStart(comments.offset);
            final length = comments.end - offset;
            builder.writeln(utils.getText(offset, length));
          }

          final text = rewriteWidgetMemberReferences(member);
          builder.write(text);
          // Write empty lines between members, but not before the first.
          writeEmptyLine = true;
        }

        builder.write('}');
      });
    });
  }

  MethodDeclaration? _findBuildMethod(ClassDeclaration widgetClass) {
    for (final member in widgetClass.members2) {
      if (member is MethodDeclaration && member.name.lexeme == 'build') {
        final parameters = member.parameters;
        if (parameters != null && parameters.parameters.length == 1) {
          return member;
        }
      }
    }
    return null;
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
      final offset = node.offset - linesRange.offset;
      final qualifier = element.isStatic
          ? componentClassElement.displayName
          : 'component';

      final parent = node.parent;
      if (parent is InterpolationExpression &&
          parent.leftBracket.type ==
              TokenType.STRING_INTERPOLATION_IDENTIFIER) {
        edits.add(SourceEdit(offset, 0, '{$qualifier.'));
        edits.add(SourceEdit(offset + node.length, 0, '}'));
      } else {
        edits.add(SourceEdit(offset, 0, '$qualifier.'));
      }
    }
  }
}
