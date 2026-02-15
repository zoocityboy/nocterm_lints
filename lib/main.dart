import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:nocterm_lints/nocterm/nocterm_convert_to_stateful_widget.dart';
import 'nocterm/nocterm_convert_to_stateless_widget.dart';
import 'nocterm/nocterm_move_down.dart';
import 'nocterm/nocterm_move_up.dart';
import 'nocterm/nocterm_remove_widget.dart';
import 'nocterm/nocterm_swap_with_child.dart';
import 'nocterm/nocterm_swap_with_parent.dart';
import 'nocterm/nocterm_wrap_builder.dart';
import 'nocterm/nocterm_wrap_column.dart';
import 'nocterm/nocterm_wrap_component.dart';
import 'nocterm/nocterm_wrap_center.dart';
import 'nocterm/nocterm_wrap_container.dart';
import 'nocterm/nocterm_wrap_expanded.dart';
import 'nocterm/nocterm_wrap_flexible.dart';
import 'nocterm/nocterm_wrap_generic.dart';
import 'nocterm/nocterm_wrap_padding.dart';
import 'nocterm/nocterm_wrap_row.dart';
import 'nocterm/nocterm_wrap_sized_box.dart';

final plugin = NoctermLintsPlugin();

/// Modern analysis server plugin for Nocterm assists and lints.
class NoctermLintsPlugin extends Plugin {
  @override
  String get name => 'nocterm_lints';

  @override
  void register(PluginRegistry registry) {
    /// Widget manipulation assists
    registry.registerAssist(NoctermMoveDown.new);
    registry.registerAssist(NoctermMoveUp.new);
    registry.registerAssist(NoctermRemoveWidget.new);
    registry.registerAssist(NoctermSwapWithChild.new);
    registry.registerAssist(NoctermSwapWithParent.new);

    /// Component wrapping assists
    registry.registerAssist(NoctermWrapComponent.new);
    registry.registerAssist(NoctermWrapGeneric.new);
    registry.registerAssist(NoctermWrapCenter.new);
    registry.registerAssist(NoctermWrapContainer.new);
    registry.registerAssist(NoctermWrapExpanded.new);
    registry.registerAssist(NoctermWrapFlexible.new);
    registry.registerAssist(NoctermWrapPadding.new);
    registry.registerAssist(NoctermWrapSizedBox.new);
    registry.registerAssist(NoctermWrapRow.new);
    registry.registerAssist(NoctermWrapColumn.new);

    /// Builder wrap assists
    registry.registerAssist(NoctermWrapBuilder.new);
    registry.registerAssist(NoctermWrapValueListenableBuilder.new);

    /// Widget conversion assists
    registry.registerAssist(NoctermConvertToStatefulWidget.new);
    registry.registerAssist(NoctermConvertToStatelessWidget.new);
  }
}
