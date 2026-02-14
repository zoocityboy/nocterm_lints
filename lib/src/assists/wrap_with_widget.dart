import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'logger.dart';
import 'utils.dart';

/// Assist to wrap a component with a generic Widget.
class WrapWithWidget extends ResolvedCorrectionProducer {
  WrapWithWidget({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => AssistKind('dart.assist.nocterm.wrapWithWidget', 30, "Wrap with Widget");

  @override
  Future<void> compute(ChangeBuilder builder) async {
    AssistLogger().logAssist('WrapWithWidget', file, node.offset);

    final componentExpr = node.findComponentExpression;
    if (componentExpr == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(componentExpr), (builder) {
        builder.addSimpleLinkedEdit('WIDGET', 'Component');
        builder.write('(');
        builder.writeln();
        final indentOld = utils.getLinePrefix(componentExpr.offset);
        final indentNew = '$indentOld${utils.oneIndent}';
        builder.write(indentNew);
        builder.write('child: ');
        builder.write(utils.replaceSourceIndent(utils.getNodeText(componentExpr), indentOld, indentNew));
        builder.writeln();
        builder.write(indentOld);
        builder.write(')');
      });
    });
  }
}
