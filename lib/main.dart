import 'dart:developer';

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'assistants/convert_to_stateful_component.dart';
import 'assistants/convert_to_stateless_component.dart';
import 'assistants/move_down.dart';
import 'assistants/move_up.dart';
import 'assistants/remove_widget.dart';
import 'assistants/swap_with_child.dart';
import 'assistants/swap_with_parent.dart';
import 'assistants/wrap_builder.dart';
import 'assistants/wrap_center.dart';
import 'assistants/wrap_column.dart';
import 'assistants/wrap_component.dart';
import 'assistants/wrap_container.dart';
import 'assistants/wrap_expanded.dart';
import 'assistants/wrap_flexible.dart';
import 'assistants/wrap_generic.dart';
import 'assistants/wrap_padding.dart';
import 'assistants/wrap_row.dart';
import 'assistants/wrap_sized_box.dart';

final plugin = NoctermLintsPlugin();

/// Modern analysis server plugin for Nocterm assists and lints.
class NoctermLintsPlugin extends Plugin {
  @override
  String get name => 'nocterm_lints';

  @override
  void register(PluginRegistry registry) {
    try {
      /// Widget manipulation assists
      registry.registerAssist(MoveDown.new);
      registry.registerAssist(MoveUp.new);
      registry.registerAssist(RemoveWidget.new);
      registry.registerAssist(SwapWithChild.new);
      registry.registerAssist(SwapWithParent.new);

      /// Component wrapping assists
      registry.registerAssist(WrapComponent.new);
      registry.registerAssist(WrapGeneric.new);
      registry.registerAssist(WrapCenter.new);
      registry.registerAssist(WrapContainer.new);
      registry.registerAssist(WrapExpanded.new);
      registry.registerAssist(WrapFlexible.new);
      registry.registerAssist(WrapPadding.new);
      registry.registerAssist(WrapSizedBox.new);
      registry.registerAssist(WrapRow.new);
      registry.registerAssist(WrapColumn.new);

      /// Builder wrap assists
      registry.registerAssist(WrapBuilder.new);
      registry.registerAssist(WrapValueListenableBuilder.new);

      /// Widget conversion assists
      registry.registerAssist(ConvertToStatefulWidget.new);
      registry.registerAssist(ConvertToStatelessWidget.new);
    } catch (e, stackTrace) {
      log(
        '[nocterm_lints] registering assists: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
