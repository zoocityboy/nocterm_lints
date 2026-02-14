import 'package:analyzer_plugin/utilities/assist/assist.dart';

import 'utils.dart';

/// Assist to wrap a component with Center.
class WrapWithCenter extends WrapSingleComponent {
  WrapWithCenter({required super.context});

  @override
  AssistKind get assistKind =>
      AssistKind('dart.assist.nocterm.wrapWithCenter', 30, "Wrap with Center");

  @override
  String get parentClassName => 'Center';
}
