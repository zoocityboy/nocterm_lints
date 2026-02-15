/// Utilities for working with ASCII character codes as integers.
extension AsciiCharacterCodeExtension on int {
  /// Whether this character code represents a digit (0-9).
  bool get isAsciiDigit => this >= 0x30 && this <= 0x39;

  /// Whether this character code represents a letter (a-z, A-Z).
  bool get isAsciiLetter =>
      (this >= 0x41 && this <= 0x5A) || (this >= 0x61 && this <= 0x7A);

  /// Whether this character code represents a letter or digit.
  bool get isAsciiLetterOrDigit => isAsciiLetter || isAsciiDigit;

  /// Whether this character code represents a letter, digit, or underscore.
  ///
  /// Useful for validating identifier characters.
  bool get isAsciiLetterOrDigitOrUnderscore =>
      isAsciiLetter || isAsciiDigit || isAsciiUnderscore;

  /// Whether this character code represents a space or tab character.
  bool get isAsciiSpace => this == 0x20 || this == 0x09;

  /// Whether this character code represents an underscore.
  bool get isAsciiUnderscore => this == 0x5F;

  /// Whether this character code represents a space, tab, newline,
  /// or carriage return.
  bool get isAsciiWhitespace => isAsciiSpace || isAsciiEndOfLine;

  /// Whether this character code represents a newline or carriage return.
  bool get isAsciiEndOfLine => this == 0x0D || this == 0x0A;
}

/// Utilities for formatting iterables of strings.
extension StringIterableFormattingExtension on Iterable<String> {
  /// Returns a comma-separated string with the last element preceded by 'and'.
  ///
  /// Examples:
  /// - ['a', 'b'] → "a and b"
  /// - ['a', 'b', 'c'] → "a, b, and c"
  String get commaSeparatedWithAnd => _formatWithConjunction('and');

  /// Returns a comma-separated string with the last element preceded by 'or'.
  ///
  /// Examples:
  /// - ['a', 'b'] → "a or b"
  /// - ['a', 'b', 'c'] → "a, b, or c"
  String get commaSeparatedWithOr => _formatWithConjunction('or');

  /// Returns a comma-separated string with single quotes around each element
  /// and the last element preceded by 'and'.
  ///
  /// Examples:
  /// - ['a', 'b'] → "'a' and 'b'"
  /// - ['a', 'b', 'c'] → "'a', 'b', and 'c'"
  String get quotedAndCommaSeparatedWithAnd =>
      _formatWithConjunction('and', quoted: true);

  /// Returns a comma-separated string with single quotes around each element
  /// and the last element preceded by 'or'.
  ///
  /// Examples:
  /// - ['a', 'b'] → "'a' or 'b'"
  /// - ['a', 'b', 'c'] → "'a', 'b', or 'c'"
  String get quotedAndCommaSeparatedWithOr =>
      _formatWithConjunction('or', quoted: true);

  /// Formats this iterable as a comma-separated string with [conjunction].
  ///
  /// If [quoted] is true, each element is wrapped in single quotes.
  String _formatWithConjunction(String conjunction, {bool quoted = false}) {
    final iterator = this.iterator;

    // Empty list
    if (!iterator.moveNext()) {
      return '';
    }
    final first = iterator.current;

    // Single element
    if (!iterator.moveNext()) {
      return quoted ? "'$first'" : first;
    }
    final second = iterator.current;

    // Two elements
    if (!iterator.moveNext()) {
      return quoted
          ? "'$first' $conjunction '$second'"
          : '$first $conjunction $second';
    }
    final third = iterator.current;

    final buffer = StringBuffer();
    _appendFormattedElement(buffer, first, quoted);
    buffer.write(', ');
    _appendFormattedElement(buffer, second, quoted);

    var nextToWrite = third;
    while (iterator.moveNext()) {
      buffer.write(', ');
      _appendFormattedElement(buffer, nextToWrite, quoted);
      nextToWrite = iterator.current;
    }
    buffer.write(', ');
    buffer.write(conjunction);
    buffer.write(' ');
    _appendFormattedElement(buffer, nextToWrite, quoted);
    return buffer.toString();
  }

  /// Appends [element] to [buffer], optionally wrapped in single quotes.
  void _appendFormattedElement(
    StringBuffer buffer,
    String element,
    bool quoted,
  ) {
    if (quoted) {
      buffer.write("'");
    }
    buffer.write(element);
    if (quoted) {
      buffer.write("'");
    }
  }
}

/// Utilities for string pluralization.
extension PluralizedStringExtension on String {
  /// Returns this string pluralized (appends 's') if [count] is not 1.
  ///
  /// Examples:
  /// - "item".pluralized(1) → "item"
  /// - "item".pluralized(2) → "items"
  /// - "item".pluralized(0) → "items"
  String pluralized(int count) => count == 1 ? toString() : '${toString()}s';
}

/// Utilities for string manipulation and transformation.
extension StringUtilitiesExtension on String {
  /// Truncates this string to [limit] characters,
  /// replacing the middle with '...'.
  ///
  /// If this string's length exceeds [limit],
  /// the middle is replaced with '...'
  /// to maintain approximately equal head and tail visibility.
  ///
  /// Examples:
  /// - "hello".elideTo(10) → "hello" (unchanged, under limit)
  /// - "hello world test".elideTo(12) → "hello...test"
  String elideTo(int limit) {
    if (length > limit) {
      final headLength = limit ~/ 2 - 1;
      final tailLength = limit - headLength - 3;
      return '${substring(0, headLength)}...${substring(length - tailLength)}';
    }
    return this;
  }

  /// Returns a prefix-removed version if this string starts with [prefix],
  /// otherwise returns this string unchanged.
  ///
  /// Examples:
  /// - "prefixtest".removePrefixOrSelf("prefix") → "test"
  /// - "test".removePrefixOrSelf("prefix") → "test"
  String removePrefixOrSelf(String prefix) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    } else {
      return this;
    }
  }

  /// Removes the [suffix] from this string if it ends with [suffix].
  ///
  /// Returns null if this string does not end with [suffix].
  ///
  /// Examples:
  /// - "test.txt".removeSuffix(".txt") → "test"
  /// - "test".removeSuffix(".txt") → null
  String? removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    } else {
      return null;
    }
  }

  /// Converts camelCase or PascalCase to SCREAMING_SNAKE_CASE.
  ///
  /// Handles common cases like acronyms and digit boundaries.
  ///
  /// Examples:
  /// - camelCase → CAMEL_CASE
  /// - HTTPRequest → HTTP_REQUEST
  /// - myURLId2Parser → MY_URL_ID_2_PARSER
  /// - _privateField → _PRIVATE_FIELD
  String toScreamingSnakeCase() {
    if (isEmpty) return this;

    // Preserve leading underscores (e.g., Dart private members).
    final leading = RegExp('^_+').stringMatch(this) ?? '';
    var result = substring(leading.length);

    // Split lower/digit -> Upper (e.g., "fooBar" -> "foo_Bar", "v2X" -> "v2_X").
    result = result.replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (match) => '${match[1]}_${match[2]}',
    );

    // Split acronym -> Word (e.g., "HTMLParser" -> "HTML_Parser").
    result = result.replaceAllMapped(
      RegExp('([A-Z]+)([A-Z][a-z])'),
      (match) => '${match[1]}_${match[2]}',
    );

    // Separate letters and digits both ways (e.g., "ID10T" -> "ID_10_T").
    result = result.replaceAllMapped(
      RegExp('([A-Za-z])([0-9])'),
      (match) => '${match[1]}_${match[2]}',
    );
    result = result.replaceAllMapped(
      RegExp('([0-9])([A-Za-z])'),
      (match) => '${match[1]}_${match[2]}',
    );

    // Normalize separators and scream.
    result = result.replaceAll(RegExp('_+'), '_');
    return leading + result.toUpperCase();
  }
}
