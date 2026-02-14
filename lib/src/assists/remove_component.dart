import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'logger.dart';
import 'utils.dart';

/// Assist to remove a component wrapper and keep its child.
class RemoveComponent extends ResolvedCorrectionProducer {
  RemoveComponent({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => AssistKind('dart.assist.nocterm.removeComponent', 30, "Remove this component");

  @override
  Future<void> compute(ChangeBuilder builder) async {
    AssistLogger().logAssist('RemoveComponent', file, node.offset);

    final componentExpr = node.findComponentExpression;
    if (componentExpr is! InstanceCreationExpression) return;

    // Find the 'child' argument
    Expression? childArg;
    for (final arg in componentExpr.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'child') {
        childArg = arg.expression;
        break;
      }
    }

    if (childArg == null) return;

    final childSrc = utils.getNodeText(childArg);
    final indentOld = utils.getLinePrefix(componentExpr.offset);
    final indentNew = utils.getLinePrefix(childArg.offset);

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(componentExpr), (builder) {
        final adjustedSrc = utils.replaceSourceIndent(childSrc, indentNew, indentOld);
        builder.write(adjustedSrc);
      });
    });
  }
}
