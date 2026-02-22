# Changelog

## [0.4.0+beta.3](https://github.com/zoocityboy/nocterm_lints/compare/nocterm_lints-v0.3.0+beta.3...nocterm_lints-v0.4.0+beta.3) (2026-02-22)


### Features

* add CI workflow for linting, formatting, and testing ([6be906e](https://github.com/zoocityboy/nocterm_lints/commit/6be906ef30526658e6297b5abde383b845fa791b))
* add CI/CD release workflow and configuration files for automated versioning and changelog updates ([187f765](https://github.com/zoocityboy/nocterm_lints/commit/187f765bc48fa3f9340e45d26cc4057eceb728d4))
* Add extensions for Dart elements and Nocterm components ([98d11c7](https://github.com/zoocityboy/nocterm_lints/commit/98d11c73cc1cadd7069590a0def76474eddfbc2b))
* add launch configuration and implement tests for component conversion assists ([86afcd1](https://github.com/zoocityboy/nocterm_lints/commit/86afcd14423c06ba2379b01eb110a0a924b91077))
* add pre-commit and pre-push hooks for linting and testing, update dependencies ([c8a2e02](https://github.com/zoocityboy/nocterm_lints/commit/c8a2e025dfd3b282570af5dbc6803372f382f81d))
* add utility extensions for AST, elements, and string manipulation ([7c2cd1b](https://github.com/zoocityboy/nocterm_lints/commit/7c2cd1b677fc3421a469c2d072898103768f270d))
* clean up imports and comment out unused variable in Nocterm files ([fd8be6c](https://github.com/zoocityboy/nocterm_lints/commit/fd8be6c5453263e0cbd7d05257298293fe0b37ce))
* enhance analysis options and improve logging messages ([0252923](https://github.com/zoocityboy/nocterm_lints/commit/02529231dc8c16652943e07d04eb233cab72e799))
* ignore experimental_member_use error in analysis options ([9d11ae6](https://github.com/zoocityboy/nocterm_lints/commit/9d11ae66127ba68ebe70c5622d1c05f3be0cc150))
* initial commit of nocterm_lints plugin with assists and lints ([26d1a10](https://github.com/zoocityboy/nocterm_lints/commit/26d1a10981ef9255fc71d98a926c4bd2c32c2135))
* **logger:** add method to create logger instance with file in app directory ([5fcb05c](https://github.com/zoocityboy/nocterm_lints/commit/5fcb05cacf8f141494c10ab7572e9ac82690a50f))
* **logging:** integrate NoctermLogger for enhanced logging capabilities ([cf6e927](https://github.com/zoocityboy/nocterm_lints/commit/cf6e9270a84702263cbb86a572a0f4686fc1fe12))
* refactor assist kinds and add session helper extension for Nocterm ([babff98](https://github.com/zoocityboy/nocterm_lints/commit/babff983c4482a1a1aeb8a5c1cda48444510a9b9))
* Refactor assistant filenames and update documentation for migration ([8da5ec9](https://github.com/zoocityboy/nocterm_lints/commit/8da5ec91ca9d17feba8d04510a6d4ef92603ba26))
* remove unused imports from multiple Nocterm files ([4edf41d](https://github.com/zoocityboy/nocterm_lints/commit/4edf41d460cd3d1d398d5c3d0fa7356244a6de42))
* rename assist kinds for stateful and stateless widget conversions ([856b10b](https://github.com/zoocityboy/nocterm_lints/commit/856b10b30cb5ec3b48b0406f0ff231229836ecef))
* update analysis options and add Nocterm component snippets ([352ea8f](https://github.com/zoocityboy/nocterm_lints/commit/352ea8f1146a99093ab2a09bdce73d6f2da0e1a3))
* update analysis options and add recommended lints configuration ([f205fb1](https://github.com/zoocityboy/nocterm_lints/commit/f205fb1878fd0cc6ac32978aa98a146a4d2fd3b7))
* update assist kind description and remove unused wrap stream builder ([01e1eb9](https://github.com/zoocityboy/nocterm_lints/commit/01e1eb9c52873e032a1d652f8a24a52af4ad55fd))
* update import statement for token package in NoctermConvertToStatelessWidget ([2bea628](https://github.com/zoocityboy/nocterm_lints/commit/2bea6288c73b392022f299a617a9585a7e2ed130))
* update import statement for token package in NoctermConvertToStatelessWidget ([4d5eda3](https://github.com/zoocityboy/nocterm_lints/commit/4d5eda37e58ae11d9163e06b32221815c2f8fba3))
* update version to 0.2.0-dev.1 and enhance project documentation ([16b3bf8](https://github.com/zoocityboy/nocterm_lints/commit/16b3bf8798f9f6c65baefa084e594d8d2df9abeb))
* update version to 0.2.0-dev.2 and fix typo in CHANGELOG ([914f768](https://github.com/zoocityboy/nocterm_lints/commit/914f768c97d5f10d7d75f3cdda88dc7e73fc9dde))
* update version to 0.3.0+beta.1 and correct tag format in CHANGELOG ([8c0bc91](https://github.com/zoocityboy/nocterm_lints/commit/8c0bc91e422ba0fca4faf498b5db8209351bcf30))
* update version to 0.3.0+beta.2 in pubspec.yaml ([522bfcf](https://github.com/zoocityboy/nocterm_lints/commit/522bfcf3f12c86e4e711fb07fb35901b9a5bc1d4))
* update version to 0.3.0+dev.1 and fix tag format in CHANGELOG ([d054448](https://github.com/zoocityboy/nocterm_lints/commit/d054448b593111ad4ce6840a469a65355898a45a))

## 0.3.0+beta.3
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

## 0.3.0+beta.2

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


## 0.3.0+beta.1
  
- **chore**: wrong format of tag versions

## 0.2.0-dev.2

- **chore**: typo

## 0.2.0-dev.1

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

## 0.1.0-dev.1+2
    
- initial version
