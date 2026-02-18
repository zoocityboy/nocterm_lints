# 0.3.0+beta.3
- **refactor**: simplified assist registration and structure
  - Consolidated producer implementations for improved maintainability
  - Updated registration pattern in `lib/main.dart`

- **feat**: enhanced analyzer plugin compatibility
  - Verified compatibility with latest `analysis_server_plugin` versions
  - Improved error handling in assist producers

- **docs**: updated documentation
  - Refreshed CHANGELOG formatting
  - Updated README examples for clarity

- **chore**: code cleanup
  - Removed obsolete files and imports

# 0.3.0+beta.2

- **refactor**: removed `Nocterm` prefix from assistant filenames and exported class names
  - Renamed assistant files under `lib/src/assistants/` to drop the `nocterm_` prefix (for example
    `nocterm_wrap_center.dart` → `wrap_center.dart`).
  - Updated exported class names accordingly (for example `NoctermWrapCenter` → `WrapCenter`).
  - Updated `lib/main.dart` to import and register the new class names.

- **chore**: remove legacy files
  - Deleted legacy `nocterm_*` assistant files after creating the renamed replacements.

- **feature**: added/adjusted assists
  - Added `remove_widget.dart` (`RemoveWidget`) and other per-assist producer files as part of the wrap refactor.

- **docs**: README and acknowledgments updated
  - Updated `README.md` project structure and usage examples to reference the new filenames.
  - Updated `ACKNOWLEDGMENTS.md` to reflect renamed assists and provide attribution.

- **notes / migration**:
  - If you depend on the old `nocterm_*` filenames or the exported `Nocterm*` class names, update imports to the new paths and identifiers.
  - Run `dart analyze` and `dart test` locally; after the mass rename some environment-specific imports or plugin AOT compilation may need minor fixes.


# 0.3.0+beta.1
  
- **chore**: wrong format of tag versions

# 0.2.0-dev.2

- **chore**: typo

# 0.2.0-dev.1

## Features

- **9 new individual wrap producers**: Refactored from monolithic `NoctermWrap` MultiCorrectionProducer to 9 independent `ResolvedCorrectionProducer` classes
  - `NoctermWrapGeneric`, `NoctermWrapCenter`, `NoctermWrapContainer`
  - `NoctermWrapExpanded`, `NoctermWrapFlexible`, `NoctermWrapPadding`, `NoctermWrapSizedBox`
  - `NoctermWrapRow`, `NoctermWrapColumn`
  - Auto-discoverable pattern: context-only instantiation with applicability checks in `compute()` method

- **Complete project legalization**: Dual-licensed for compliance
  - Maintained MIT for new code
  - Preserved BSD-3-Clause for Dart-derived code (19 files)
  - Updated all copyright headers with proper attribution

## Improvements

- **Extension utilities refactoring** (`string.dart`):
  - Renamed `IntExtension` → `AsciiCharacterCodeExtension` for clarity
  - Renamed `IterableOfStringExtension` → `StringIterableFormattingExtension`
  - Renamed `Pluralized` → `PluralizedStringExtension`
  - Renamed `StringExtension` → `StringUtilitiesExtension`
  - Improved ASCII character code getters with consistent naming (`isAsciiDigit`, `isAsciiLetter`, etc.)
  - Enhanced documentation with practical examples

- **Removed unused getters**: Deleted unused extension methods to reduce API surface
  - `isComma`, `isEqual`, `isLF`, `isSlash`, `nullIfNegative`
  - `nullIfEmpty`, `ifEqualThen`, `ifNotEmptyOrElse`

- **README redesign**: Complete restructuring for professional documentation
  - Added strong value proposition and clear feature categorization (19 assists × 4 categories)
  - Improved "Getting Started" section with development/published package distinction
  - Added practical usage examples with before/after code
  - Professional requirements matrix in table format
  - Added project structure visualization
  - Cleaner, more accessible styling

- **Created ACKNOWLEDGMENTS.md**: Comprehensive attribution documentation
  - Detailed listing of all Dart-derived files (19 files with specific assists/extensions)
  - Explanation of modifications made to derived code
  - License compliance approach documentation

- **Enhanced LICENSE file**: Dual-license structure with clear separation
  - Original Dart project code: BSD-3-Clause license
  - New and modified code: MIT License
  - Detailed file attribution and compliance notes

## Breaking Changes

- **Removed `NoctermWrap` MultiCorrectionProducer**: Replaced with 9 individual producer classes
  - Old: Single coordinator managing multiple sub-producers
  - New: Each producer independently discoverable and registerable via `registry.registerAssist()`
  - All 19 assists still available with same functionality

## Bug Fixes

- Fixed extension visibility issues in wrap producers
- Corrected Dart analyzer compatibility with modern `analysis_server_plugin` v0.3.4

## Documentation

- All 19 files updated with dual-copyright headers
- Complete LICENSE documentation with attribution summary
- Professional README with improved accessibility
- Comprehensive ACKNOWLEDGMENTS for Dart project origin

## Dependencies

- No version changes to dependencies
- Maintained compatibility with Dart SDK >= 3.10.0
- Verified with analysis_server_plugin v0.3.4

---

# 0.1.0-dev.1+2
    
- initial version