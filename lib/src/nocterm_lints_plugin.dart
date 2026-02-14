import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'assists.dart';

/// Modern analysis server plugin for Nocterm assists and lints.
class NoctermLintsPlugin extends Plugin {
  @override
  String get name => 'nocterm_lints';

  @override
  void register(PluginRegistry registry) {
    // (No rules registered here) Rules live in `lib/src/rules.dart` when present.

    // Register wrap assists
    registry.registerAssist(WrapWithWidget.new);
    registry.registerAssist(WrapWithPadding.new);
    registry.registerAssist(WrapWithCenter.new);
    registry.registerAssist(WrapWithRow.new);
    registry.registerAssist(WrapWithColumn.new);

    // Register remove assist
    registry.registerAssist(RemoveComponent.new);

    // Register swap assists
    registry.registerAssist(SwapWithChild.new);
    registry.registerAssist(SwapWithParent.new);
  }
}
