import 'package:analyzer_plugin/utilities/assist/assist.dart';

import 'utils.dart';

/// Assist to wrap a component with Row.
class WrapWithRow extends WrapSingleComponent {
  WrapWithRow({required super.context});

  @override
  AssistKind get assistKind =>
      AssistKind('dart.assist.nocterm.wrapWithRow', 30, "Wrap with Row");

  @override
  String get parentClassName => 'Row';
}
