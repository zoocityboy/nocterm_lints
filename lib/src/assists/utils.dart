import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'logger.dart';

const String noctermUri = 'package:nocterm/nocterm.dart';

/// Extension to find a Nocterm component expression.
extension ComponentFinder on AstNode {
  Expression? get findComponentExpression {
    AstNode? node = this;
    while (node != null) {
      if (node is Expression) {
        // A component is typically an InstanceCreationExpression or MethodInvocation
        // that returns something assignable to Component.
        // For simplicity in this plugin, we'll suggest it for any Expression
        // that looks like a component (Capitalized name or known type).
        if (node is InstanceCreationExpression || node is MethodInvocation) {
          final type = node.staticType;
          if (type != null && type is InterfaceType) {
            // Check if it's a Component
            if (_isComponent(type)) {
              return node;
            }
          }
          // Fallback to name check if type is unresolved
          if (node is InstanceCreationExpression) {
            final constructorName = node.constructorName.type.toString();
            if (constructorName.isNotEmpty && constructorName[0].toUpperCase() == constructorName[0]) {
              return node;
            }
          }
        }
      }
      node = node.parent;
    }
    return null;
  }

  bool _isComponent(InterfaceType type) {
    if (type.element.name == 'Component') return true;
    for (var superType in type.allSupertypes) {
      if (superType.element.name == 'Component') return true;
    }
    return false;
  }
}

/// Abstract base class for wrapping a single Nocterm component.
abstract class WrapSingleComponent extends ResolvedCorrectionProducer {
  WrapSingleComponent({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  String get parentClassName;

  String get parentLibraryUri => noctermUri;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    AssistLogger().logAssist(assistKind?.id ?? runtimeType.toString(), file, node.offset);

    final componentExpr = node.findComponentExpression;
    if (componentExpr == null) return;

    final componentSrc = utils.getNodeText(componentExpr);
    final parentClassElement = await sessionHelper.getClass(parentLibraryUri, parentClassName);

    if (parentClassElement == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(componentExpr), (builder) {
        builder.writeReference(parentClassElement);
        builder.write('(');

        final eol = utils.endOfLine;
        final multiLine = componentSrc.contains(eol);

        if (multiLine) {
          final indentOld = utils.getLinePrefix(componentExpr.offset);
          final indentNew = '$indentOld${utils.oneIndent}';

          builder.writeln();
          builder.write(indentNew);
          builder.write('child: ');

          final indentedSrc = utils.replaceSourceIndent(componentSrc, indentOld, indentNew);
          builder.write(indentedSrc);
          builder.write(',');
          builder.writeln();
          builder.write(indentOld);
        } else {
          builder.write('child: ');
          builder.write(componentSrc);
        }
        builder.write(')');
      });
    });
  }
}
