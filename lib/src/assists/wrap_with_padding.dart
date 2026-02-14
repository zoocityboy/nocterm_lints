import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'logger.dart';
import 'utils.dart';

/// Assist to wrap a component with Padding.
class WrapWithPadding extends WrapSingleComponent {
  WrapWithPadding({required super.context});

  @override
  AssistKind get assistKind => AssistKind('dart.assist.nocterm.wrapWithPadding', 30, "Wrap with Padding");

  @override
  String get parentClassName => 'Padding';

  @override
  Future<void> compute(ChangeBuilder builder) async {
    AssistLogger().logAssist('WrapWithPadding', file, node.offset);

    final componentExpr = node.findComponentExpression;
    if (componentExpr == null) return;

    final parentClassElement = await sessionHelper.getClass(parentLibraryUri, parentClassName);

    if (parentClassElement == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(componentExpr), (builder) {
        builder.writeReference(parentClassElement);
        builder.write('(');
        builder.write('padding: const EdgeInsets.all(8.0), ');
        builder.write('child: ');
        builder.write(utils.getNodeText(componentExpr));
        builder.write(')');
      });
    });
  }
}
