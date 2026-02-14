import 'package:analyzer_plugin/utilities/assist/assist.dart';

import 'utils.dart';

/// Assist to wrap a component with Column.
class WrapWithColumn extends WrapSingleComponent {
  WrapWithColumn({required super.context});

  @override
  AssistKind get assistKind =>
      AssistKind('dart.assist.nocterm.wrapWithColumn', 30, "Wrap with Column");

  @override
  String get parentClassName => 'Column';
}
