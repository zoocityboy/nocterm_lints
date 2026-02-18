// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:nocterm_lints/utilities/logger.dart';

/// Extension methods for logging analysis operations.
extension NoctermLogging on Object {
  /// Log debug message with this class name as context.
  void logDebug(String message) {
    final context = runtimeType.toString();
    NoctermLogger.instance.debug('[$context] $message');
  }

  /// Log info message with this class name as context.
  void logInfo(String message) {
    final context = runtimeType.toString();
    NoctermLogger.instance.info('[$context] $message');
  }

  /// Log warning message with this class name as context.
  void logWarning(String message) {
    final context = runtimeType.toString();
    NoctermLogger.instance.warning('[$context] $message');
  }

  /// Log error message with this class name as context.
  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    final context = runtimeType.toString();
    NoctermLogger.instance.error('[$context] $message', error, stackTrace);
  }
}

/// Utility class for logging analysis metrics.
class AnalysisMetrics {
  static final NoctermLogger _logger = NoctermLogger.instance;

  /// Log assist execution.
  static void logAssistExecution(
    String assistName, {
    required bool success,
    required Duration duration,
    String? reason,
  }) {
    if (!success && reason != null) {
      _logger.debug('Assist $assistName skipped: $reason (${duration.inMilliseconds}ms)');
    } else if (success) {
      _logger.info('Assist $assistName executed (${duration.inMilliseconds}ms)');
    }
  }

  /// Log AST analysis.
  static void logAstAnalysis(
    String description, {
    bool found = false,
    required Duration duration,
  }) {
    _logger.debug('AST analysis: $description - ${found ? 'found' : 'not found'} '
        '(${duration.inMilliseconds}ms)');
  }

  /// Log type checking.
  static void logTypeCheck(
    String typeName, {
    required bool matched,
    required Duration duration,
  }) {
    _logger.debug('Type check: $typeName - ${matched ? 'matched' : 'not matched'} '
        '(${duration.inMilliseconds}ms)');
  }

  /// Flush all pending logs.
  static void flush() {
    _logger.flush();
  }
}
