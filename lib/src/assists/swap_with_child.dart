import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'logger.dart';
import 'utils.dart';

/// Assist to swap a component with its child.
class SwapWithChild extends ResolvedCorrectionProducer {
  SwapWithChild({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => AssistKind('dart.assist.nocterm.swapWithChild', 30, "Swap with child");

  @override
  Future<void> compute(ChangeBuilder builder) async {
    AssistLogger().logAssist('SwapWithChild', file, node.offset);

    final componentExpr = node.findComponentExpression;
    if (componentExpr is! InstanceCreationExpression) return;

    // Find the 'child' argument
    NamedExpression? childArg;
    for (final arg in componentExpr.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'child') {
        childArg = arg;
        break;
      }
    }

    if (childArg == null) return;
    final childExpr = childArg.expression;

    // Child must also be a component with a 'child' argument
    if (childExpr is! InstanceCreationExpression) return;

    NamedExpression? grandchildArg;
    for (final arg in childExpr.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'child') {
        grandchildArg = arg;
        break;
      }
    }

    if (grandchildArg == null) return;

    await builder.addDartFileEdit(file, (builder) {
      final parentSrc = utils.getNodeText(componentExpr);
      final childSrc = utils.getNodeText(childExpr);
      final grandchildSrc = utils.getNodeText(grandchildArg!.expression);

      // Build: child( ... child: parent( ... child: grandchild))
      final newParentWithGrandchild = parentSrc.replaceFirst(utils.getNodeText(childArg!.expression), grandchildSrc);

      final newChildWithParent = childSrc.replaceFirst(
        utils.getNodeText(grandchildArg.expression),
        newParentWithGrandchild,
      );

      builder.addReplacement(range.node(componentExpr), (builder) {
        builder.write(newChildWithParent);
      });
    });
  }
}
