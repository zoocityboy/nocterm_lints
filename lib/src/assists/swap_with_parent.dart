import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'logger.dart';
import 'utils.dart';

/// Assist to swap a component with its parent.
class SwapWithParent extends ResolvedCorrectionProducer {
  SwapWithParent({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => AssistKind('dart.assist.nocterm.swapWithParent', 30, "Swap with parent");

  @override
  Future<void> compute(ChangeBuilder builder) async {
    AssistLogger().logAssist('SwapWithParent', file, node.offset);

    final componentExpr = node.findComponentExpression;
    if (componentExpr is! InstanceCreationExpression) return;

    // Find parent component (must have this as child argument)
    final parent = componentExpr.parent;
    if (parent is! NamedExpression) return;
    if (parent.name.label.name != 'child') return;

    final argumentList = parent.parent;
    if (argumentList is! ArgumentList) return;

    final parentComponent = argumentList.parent;
    if (parentComponent is! InstanceCreationExpression) return;

    // Find child of current component
    NamedExpression? childArg;
    for (final arg in componentExpr.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'child') {
        childArg = arg;
        break;
      }
    }

    if (childArg == null) return;

    await builder.addDartFileEdit(file, (builder) {
      final parentSrc = utils.getNodeText(parentComponent);
      final currentSrc = utils.getNodeText(componentExpr);
      final childSrc = utils.getNodeText(childArg!.expression);

      // Build: current( ... child: parent( ... child: child))
      final newParentWithChild = parentSrc.replaceFirst(utils.getNodeText(componentExpr), childSrc);

      final newCurrentWithParent = currentSrc.replaceFirst(utils.getNodeText(childArg.expression), newParentWithChild);

      builder.addReplacement(range.node(parentComponent), (builder) {
        builder.write(newCurrentWithParent);
      });
    });
  }
}
