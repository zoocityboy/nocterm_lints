# nocterm_lints

`nocterm_lints` is an analysis server plugin that provides IDE assists and lints tailored for Nocterm terminal UI components. It uses the modern `analysis_server_plugin` framework to deliver quick-fixes, refactor assists, and diagnostics that speed up authoring Nocterm-based UI code.

> [!note]
> This README focuses on using the plugin during development. If you are integrating the published package, replace local `path:` references with the package version.

## Highlights

- Editor assists for common refactorings and wrappers (wrap with padding/center/row/column, swap parent/child, remove wrapper).
- Small, focused lint rules (example: discourage `print()` in production code).
- Built as an `analysis_server_plugin` so assists show up in VS Code and JetBrains IDEs via the Dart analysis server.

## Quick Start

1. Add the plugin to your project's `analysis_options.yaml`.

Local (during development in a monorepo):

```yaml
include: package:nocterm_lints/recommended.yaml

plugins:
  nocterm_lints:
    path: ../packages/nocterm_lints
```

Published package (replace with actual version when published):

```yaml
include: package:nocterm_lints/recommended.yaml

plugins:
  nocterm_lints: ^0.1.0
```

> [!warning]
> After changing `analysis_options.yaml`, restart the Dart Analysis Server to activate plugin assists and diagnostics.

### Restart Analysis Server

- VS Code: `Cmd+Shift+P` → `Dart: Restart Analysis Server`
- IntelliJ / Android Studio: Tools → Dart Analysis Server → Restart

## Features

### Assists
- Wrap with Widget — wrap an expression with a generic container and edit constructor arguments.
- Wrap with Padding — insert a `Padding(...)` wrapper with a sensible default.
- Wrap with Center — center a child component.
- Wrap with Row / Column — wrap to create horizontal/vertical layout.
- Remove this component — remove an unnecessary wrapper while preserving its child.
- Swap with child / parent — swap positions between a widget and its parent/child to quickly refactor layout.

### Lints
- `no_print_rule` — flags uses of `print()` intended to discourage debug-only printing in production code.

## Example

Before (typical case):

```dart
// some_widget.dart
final widget = MyComponent(child: Text('Hello'));
```

After invoking the "Wrap with Padding" assist (editor command palette / quick fix):

```dart
final widget = Padding(
  padding: const EdgeInsets.all(8),
  child: MyComponent(child: Text('Hello')),
);
```

Use the editor's quick-fix shortcut (`Cmd+.` on macOS or `Ctrl+.` on Windows/Linux) to see available assists when the caret is on a Nocterm component.

## Configuration

You can enable or disable diagnostics from the plugin in `analysis_options.yaml`:

```yaml
plugins:
  nocterm_lints:
    path: ../packages/nocterm_lints
    diagnostics:
      no_print_rule: true
```

When published, the package also exposes `recommended.yaml` which you can `include:` to get sensible defaults.

## Development

This repository uses the `analysis_server_plugin` framework and follows the Rabbit Project conventions.

Clone the repository and bootstrap workspace dependencies (monorepo root):

```bash
melos bootstrap
```

From the package directory you can run tests and format code:

```bash
dart pub get
dart test
dart format .
```

If you are developing the plugin and want to test it against a local project, add it to that project's `analysis_options.yaml` using a `path:` pointing to this package, then restart the analysis server.

## Testing

Unit tests for assists and rules live under the `test/` directory. Run them with `dart test` from the package root. Tests exercise assist generation and expected source edits.

## Compatibility & Requirements

- Dart SDK >= 3.11.0
- `analysis_server_plugin` (used by the plugin) compatible with Dart 3.10+

## Where to look next

- Source: `lib/src/nocterm_lints_plugin.dart` — plugin entry point.
- Assists: `lib/src/assists.dart` and `lib/src/assists/` — individual assist implementations.
- Rules: `lib/src/rules.dart` — diagnostics and lint rule registrations.

### Adding rules (optional)

Rules are optional and may live in `lib/src/rules.dart`. When present, implement rules by extending `AnalysisRule` and register them from the plugin `register` method with `registry.registerLintRule(...)` or `registry.registerWarningRule(...)`.

Minimal example for `lib/src/rules.dart`:

```dart
import 'package:analysis_server_plugin/plugin/registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analysis_server_plugin/utilities/rule.dart';

class NoPrintRule extends AnalysisRule {
  static const code = LintCode('no_print_rule', 'Avoid using print() in production.');

  NoPrintRule() : super(code: code, message: 'Avoid using print()');

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addVisitor((node) {
      if (node is MethodInvocation && node.methodName.name == 'print') {
        rule.reportAtNode(node);
      }
    });
  }
}
```

Register the rule from `lib/src/nocterm_lints_plugin.dart`:

```dart
registry.registerLintRule(NoPrintRule());
```

Enable the lint in a project's `analysis_options.yaml` under the plugin name:

```yaml
plugins:
  nocterm_lints:
    diagnostics:
      no_print_rule: true
```

This README intentionally leaves the package without built-in rules. If you want, I can add the example `NoPrintRule` implementation into `lib/src/rules.dart` and re-enable its registration — say the word and I'll add it.
