<!-- <p align="center">
<img src="https://raw.githubusercontent.com/zoocityboy/nocterm_lints/refs/heads/main/assets/nocterm_lints.png" height="100" alt="Bloc">
</p> -->

# nocterm_lints


[![Pub](https://img.shields.io/pub/v/nocterm_lints.svg)](https://pub.dev/packages/nocterm_lints)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart)](https://dart.dev)
[![Nocterm](https://img.shields.io/badge/NOCTERM-f2f2f2?logo=nocterm&logoColor=000000)](https://nocterm.dev)
**Productivity assists for Nocterm terminal UI development**

An analysis server plugin providing intelligent IDE assists and refactoring tools for building Nocterm terminal UI components. Works seamlessly in VS Code, IntelliJ IDEA, Android Studio, and other Dart-enabled editors.

> [!info]
> Built on the modern `analysis_server_plugin` framework (Dart 3.10+). Originally derived from Dart project foundations and enhanced for Nocterm-specific workflows.

## Features

**19 productivity assists** organized into four categories:

### Component Manipulation (5)
- **Move Up/Down** — Reorder components up or down in the tree
- **Swap with Child** — Exchange positions with immediate child
- **Swap with Parent** — Exchange positions with parent component  
- **Remove Component** — Delete wrapper while preserving children

### Component Wrapping (10)
- **Wrap with Component** — Choose from available component types
- **Wrap with Generic** — Container with customizable child
- **Wrap with Center** — Center-align component
- **Wrap with Container** — Add styling container
- **Wrap with Padding** — Add spacing (default: 8dp)
- **Wrap with Row/Column** — Create horizontal/vertical layouts
- **Wrap with Expanded/Flexible** — Control sizing in flex contexts
- **Wrap with SizedBox** — Define explicit dimensions

### Layout Builders (2)
- **Wrap with Builder** — Builder pattern wrapper
- **Wrap with ValueListenableBuilder** — Reactive state pattern

### Component Conversion (2)
- **Convert to Stateful** — Refactor to StatefulComponent
- **Convert to Stateless** — Refactor to StatelessComponent

## Getting Started

### For Development (Local Path)

Add to your project's `analysis_options.yaml`:

```yaml
include: package:nocterm_lints/recommended.yaml

plugins:
  nocterm_lints:
    path: ../path/to/nocterm_lints
```

### For Published Package

```yaml
include: package:nocterm_lints/recommended.yaml

plugins:
  nocterm_lints: ^0.1.0
```

### Activate Assists

After updating `analysis_options.yaml`, restart the Dart Analysis Server:

| Editor | Command |
|--------|---------|
| **VS Code** | `Cmd+Shift+P` → "Dart: Restart Analysis Server" |
| **IntelliJ / Android Studio** | Tools → Dart Analysis → Restart |

> [!tip]
> Use `Cmd+.` (macOS) or `Ctrl+.` (Windows/Linux) to see available assists when the cursor is on a component.

## Usage Examples

### Wrap with Padding

**Before:**
```dart
final component = MyComponent(child: Text('Hello'));
```

**After:** Invoke "Wrap with Padding" assist
```dart
final component = Padding(
  padding: const EdgeInsets.all(8),
  child: MyComponent(child: Text('Hello')),
);
```

### Convert to Stateless Component

**Before:**
```dart
class MyComponent extends StatefulComponent {
  @override
  State<MyComponent> createState() => _MyComponentState();
}

class _MyComponentState extends State<MyComponent> {
  @override
  Component build(BuildContext context) => Text('Hello');
}
```

**After:** Invoke "Convert to Stateless Component" assist
```dart
class MyComponent extends StatelessComponent {
  const MyComponent({super.key});

  @override
  Component build(BuildContext context) => Text('Hello');
}
```

## Configuration

Enable or disable diagnostics in `analysis_options.yaml`:

```yaml
plugins:
  nocterm_lints:
    path: ../nocterm_lints
```

## Development

### Setup

Bootstrap dependencies:
```bash
dart pub get
```

### Run Tests

```bash
dart test
```

### Format Code

```bash
dart format .
```

### Analyze

```bash
dart analyze
```

### Test Against Local Project

1. Add to test project's `analysis_options.yaml`:
   ```yaml
   plugins:
     nocterm_lints:
       path: /path/to/nocterm_lints
   ```

2. Restart the Dart Analysis Server

## Project Structure

```
nocterm_lints/
├── lib/
│   ├── main.dart                 # Plugin entry point
│   ├── nocterm/                  # Individual assists
│   │   ├── nocterm_wrap_*.dart
│   │   ├── nocterm_move_*.dart
│   │   ├── nocterm_convert_*.dart
│   │   └── ...
│   ├── services/                 # Core services
│   └── utilities/                # Shared extensions
├── test/                         # Unit tests
├── example/                      # Example project
├── analysis_options.yaml
├── pubspec.yaml
└── recommended.yaml              # Default lint config
```

## Requirements

| Requirement | Version |
|-------------|---------|
| Dart SDK | >= 3.10.0 |
| analysis_server_plugin | ^0.3.4 |
| analyzer | >= 8.0.0, < 10.0.0 |

## Supported Editors

- VS Code (via Dart extension)
- IntelliJ IDEA
- Android Studio
- Other Dart analyzer-compatible editors

## Licensing

Dual-licensed for compatibility:

- **New code**: [MIT License](LICENSE)
- **Derived from Dart SDK**: [BSD-3-Clause License](https://github.com/dart-lang/sdk/blob/main/LICENSE)

See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) and [LICENSE](LICENSE) for detailed attribution.
