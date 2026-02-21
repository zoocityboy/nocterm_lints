# nocterm_lints

[![ZOOCITYBOY][logo_white]][zoocityboy_link_dark]
[![ZOOCITYBOY][logo_black]][zoocityboy_link_light]

[![Pub](https://img.shields.io/pub/v/nocterm_lints.svg)](https://pub.dev/packages/nocterm_lints)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart)](https://dart.dev)
[![Nocterm](https://img.shields.io/badge/Nocterm-terminal%20UI-black)](https://pub.dev/packages/nocterm)

`nocterm_lints` is a Dart analysis server plugin focused on Nocterm UI productivity.
It provides code actions for wrapping, moving, swapping, removing, and converting Nocterm components directly in your editor.

> [!NOTE]
> The plugin targets Dart SDK `>=3.10.0 <4.0.0` and uses the modern `analysis_server_plugin` stack.

## Installation

### Use from local path (development)

```yaml
include: package:nocterm_lints/recommended.yaml

plugins:
  nocterm_lints:
    path: ../path/to/nocterm_lints
```

### Use from pub package

```yaml
include: package:nocterm_lints/recommended.yaml

plugins:
  nocterm_lints: ^0.3.0
```

After updating `analysis_options.yaml`, restart the Dart Analysis Server.

## All Assistants

The table below lists every registered assistant in this project.

| Category | Assistant | Code Action label | Description |
| --- | --- | --- | --- |
| Move | `MoveUp` | `Move component up` | Swaps the selected component with the previous sibling in a list. |
| Move | `MoveDown` | `Move component down` | Swaps the selected component with the next sibling in a list. |
| Swap | `SwapWithChild` | `Swap with child` | Swaps a parent component with its direct child when structure is valid. |
| Swap | `SwapWithParent` | `Swap with parent` | Swaps a child component with its direct parent when structure is valid. |
| Remove | `RemoveWidget` | `Remove this component` | Removes a wrapper and preserves valid `child` or `children` content when possible. |
| Wrap | `WrapComponent` | `Wrap with component...` | Wraps a selected list of components with a generic component wrapper. |
| Wrap | `WrapGeneric` | `Wrap with component...` | Wraps a single component with a generic configurable wrapper. |
| Wrap | `WrapCenter` | `Wrap with Center` | Wraps the selected component in `Center`. |
| Wrap | `WrapContainer` | `Wrap with Container` | Wraps the selected component in `Container`. |
| Wrap | `WrapExpanded` | `Wrap with Expanded` | Wraps the selected component in `Expanded` in compatible flex contexts. |
| Wrap | `WrapFlexible` | `Wrap with Flexible` | Wraps the selected component in `Flexible` in compatible flex contexts. |
| Wrap | `WrapPadding` | `Wrap with Padding` | Wraps the selected component in `Padding` with default edge insets. |
| Wrap | `WrapSizedBox` | `Wrap with SizedBox` | Wraps the selected component in `SizedBox`. |
| Wrap | `WrapRow` | `Wrap with Row` | Wraps selected component(s) in a `Row(children: [...])`. |
| Wrap | `WrapColumn` | `Wrap with Column` | Wraps selected component(s) in a `Column(children: [...])`. |
| Wrap | `WrapBuilder` | `Wrap with Builder` | Wraps the selected component in `Builder` and generates a builder closure. |
| Wrap | `WrapValueListenableBuilder` | `Wrap with ValueListenableBuilder` | Wraps the selected component in `ValueListenableBuilder`. |
| Convert | `ConvertToStatefulComponent` | `Convert to StatefulComponent` | Refactors a stateless component into StatefulComponent + State classes. |
| Convert | `ConvertToStatelessComponent` | `Convert to StatelessComponent` | Refactors eligible stateful component/state pair into a stateless component. |

## Usage

1. Place the cursor on, or inside, a Nocterm component expression.
2. Open code actions (`Cmd+.` on macOS, `Ctrl+.` on Windows/Linux).
3. Pick an assist from the list.

> [!TIP]
> If assists do not appear after install/config changes, run `Dart: Restart Analysis Server`.

## Example

Before:

```dart
return Text('hello');
```

After `Wrap with Padding`:

```dart
return Padding(
  padding: const EdgeInsets.all(8),
  child: Text('hello'),
);
```

## Development

```bash
dart pub get
dart analyze
dart test test/assistants
```

## Project Layout

```text
lib/
  main.dart
  assistants/
  services/
  utilities/
test/
  assistants/
example/
```

[logo_black]: https://raw.githubusercontent.com/zoocityboy/zoo_brand/main/styles/README/zoocityboy_dark.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/zoocityboy/zoo_brand/main/styles/README/zoocityboy_light.png#gh-dark-mode-only
[zoocityboy_link_dark]: https://github.com/zoocityboy#gh-dark-mode-only
[zoocityboy_link_light]: https://github.com/zoocityboy#gh-light-mode-only
