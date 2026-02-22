// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

// Logger utility for nocterm_lints plugin.
// ignore_for_file: use_setters_to_change_properties
// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:io';

import 'package:path/path.dart' as path;

/// Log level severity.
enum LogLevel {
  /// Debug level - most verbose.
  debug(0, 'DEBUG'),

  /// Info level - general information.
  info(1, 'INFO'),

  /// Warning level - potential issues.
  warning(2, 'WARN'),

  /// Error level - significant errors.
  error(3, 'ERROR')
  ;

  const LogLevel(this.value, this.label);
  final int value;
  final String label;
}

/// Logger for nocterm_lints plugin.
///
/// This logger writes to a file instead of using print() which would break
/// the analysis server plugin. Logging can be configured via environment
/// variables or programmatically.
///
/// Environment variables:
/// - `NOCTERM_LOG_LEVEL`: Set minimum log level (debug, info, warning, error)
/// - `NOCTERM_LOG_DIR`: Set custom log directory (defaults to temp directory)
/// - `NOCTERM_LOG_ENABLED`: Set to 'true' to enable logging
///
/// Usage:
/// ```dart
/// NoctermLogger.instance.debug('Debug message');
/// NoctermLogger.instance.info('Info message');
/// NoctermLogger.instance.warning('Warning message');
/// NoctermLogger.instance.error('Error message');
/// ```
class NoctermLogger {
  /// Private constructor.
  NoctermLogger._(this._logFile);

  // Lazily-initialized singleton instance used throughout the plugin.
  static NoctermLogger? _instance;

  /// Global shared logger instance.
  static NoctermLogger get instance => _instance ??= _createInstance();

  late final File _logFile;
  LogLevel _logLevel = LogLevel.error;
  bool _enabled = false;
  final List<String> _buffer = [];
  static const int _bufferSize = 1;

  /// Create logger for testing (internal use only).
  static NoctermLogger createForTesting(File logFile) {
    _instance = NoctermLogger._(
      logFile,
    ); // Override singleton instance for testing
    return _instance!;
  }

  /// Set log level.
  void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  /// Enable or disable logging.
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Log at debug level.
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Log at info level.
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Log at warning level.
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Log at error level.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// Flush buffered logs to file.
  void flush() {
    if (_buffer.isNotEmpty) {
      try {
        // Ensure parent directory exists
        if (!_logFile.parent.existsSync()) {
          _logFile.parent.createSync(recursive: true);
        }
        _logFile.writeAsStringSync(
          '${_buffer.join('\n')}\n',
          mode: FileMode.append,
        );
        _buffer.clear();
      } catch (e) {
        // Silently fail to avoid breaking plugin
      }
    }
  }

  /// Clear log file.
  void clear() {
    try {
      if (_logFile.existsSync()) {
        _logFile.deleteSync();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get log file path.
  String get logFilePath => _logFile.path;

  /// Internal logging method.
  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!_enabled || level.value < _logLevel.value) {
      return;
    }

    try {
      _logFile.createSync(recursive: true);
    } catch (e) {
      return; // Fail silently
    }

    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    buffer.write('[$timestamp] ');
    buffer.write('[${level.label}] ');
    buffer.write(message);

    if (error != null) {
      buffer.write('\nError: $error');
    }

    if (stackTrace != null) {
      buffer.write('\nStackTrace:\n$stackTrace');
    }

    _buffer.add(buffer.toString());

    if (_buffer.length >= _bufferSize) {
      flush();
    }
  }

  /// Create logger instance with file in app directory.
  static NoctermLogger _createInstance() {
    final logFile = File(path.join(appDir.path, 'nocterm_lints.log'));
    return NoctermLogger._(logFile);
  }

  static const String appDirName = '.nocterm_lints';

  /// Get the base directory for app configuration and data
  static Directory get appDir {
    final homeDir =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return Directory(path.join(homeDir, appDirName));
  }
}
