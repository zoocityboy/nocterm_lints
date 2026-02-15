# Acknowledgments

This project was inspired by and contains code derived from the [Dart SDK](https://github.com/dart-lang/sdk) and related Dart tooling projects.

## Dart Project Attribution

The following files and functionality are derived from the Dart project and retain their BSD-3-Clause copyright:

### Assists (lib/nocterm/)
- `convert_to_stateless_component.dart` - Derived from Dart's "convert to stateless widget" assist
- `convert_to_stateful_component.dart` - Derived from Dart's "convert to stateful widget" assist
- `move_down.dart` - Derived from Dart's widget move-down assist
- `move_up.dart` - Derived from Dart's widget move-up assist
- `remove_widget.dart` - Derived from Dart's remove-widget assist
- `swap_with_child.dart` - Derived from Dart's swap with child assist
- `swap_with_parent.dart` - Derived from Dart's swap with parent assist
- `wrap_*.dart` (all wrap variants) - Derived from Dart's widget wrapping assists
- `wrap_component.dart` - Adapted wrapping logic for Nocterm components

### Extensions (lib/utilities/extensions/)
- `ast.dart` - Derived from Dart's AST extension utilities
- `element.dart` - Derived from Dart's element extension utilities

## License Compliance

**Original Dart code** uses the BSD-3-Clause license. See: https://github.com/dart-lang/sdk/blob/main/LICENSE

**Modifications and new code** are licensed under the MIT License (Copyright 2026 zoocityboy).

This dual-licensing approach ensures compliance with both:
- The original BSD-3-Clause requirements for Dart-derived code
- MIT licensing for all new and custom implementations

## Modifications Made

The derived code has been significantly modified and adapted for the Nocterm project:

1. **Context Adaptation**: Tailored for Nocterm terminal UI components instead of general Flutter
2. **Enhanced Type Checking**: Added specific component-type validation
3. **New Features**: Added new wrapping and manipulation assists specific to Nocterm
4. **Code Quality**: Improved documentation, naming, and error handling
5. **Framework Update**: Ported to the modern `analysis_server_plugin` framework
6. **Bug Fixes**: Fixed various issues and edge cases

## Why Dual-License?

- **BSD-3-Clause (Dart)**: Required for code derived from the Dart project
- **MIT (New Work)**: Applied to original implementations and modifications
- **Compatibility**: Both licenses are permissive and compatible

## How to Use

Users of this package can:
- Use the software under MIT terms for all new/derivative code
- Use the software under BSD-3-Clause terms for Dart-derived code
- Choose whichever license is more suitable for their use case

## Questions?

If you have questions about licensing or attribution, please refer to:
- [LICENSE](LICENSE) - Full license text and details
- [README.md](README.md) - Brief license overview

Thank you to the Dart project for the excellent foundation and inspiration!
