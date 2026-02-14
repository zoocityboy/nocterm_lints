import 'dart:io';

import 'package:path/path.dart' as p;

/// Logger for nocterm_lints development and debugging.
class AssistLogger {
  static final AssistLogger _instance = AssistLogger._internal();
  static const String _logDir = '.dart_tool';
  static const String _logSubDir = 'nocterm_lints';
  static const String _logFileName = 'develop.log';

  factory AssistLogger() => _instance;

  AssistLogger._internal();

  /// Gets the safe log file path relative to workspace root.
  String _getLogPath() {
    return p.join(_logDir, _logSubDir, _logFileName);
  }

  /// Converts absolute file path to package-relative path for readability.
  String _toPackagePath(String filePath) {
    try {
      // Try to extract package-relative path
      final uri = Uri.tryParse(filePath);
      if (uri != null && uri.scheme == 'package') {
        return filePath;
      }

      // For file paths, try to get relative to workspace
      if (filePath.contains('packages/')) {
        final index = filePath.indexOf('packages/');
        return filePath.substring(index);
      }
      if (filePath.contains('apps/')) {
        final index = filePath.indexOf('apps/');
        return filePath.substring(index);
      }

      // Fallback: use basename
      return p.basename(filePath);
    } catch (e) {
      return p.basename(filePath);
    }
  }

  /// Logs a message to the development log file and VS Code debug console.
  void log(String message) {
    try {
      // Log to VS Code debug console (visible when plugin is running)
      print('[nocterm_lints] $message');

      // Also append to log file
      final logPath = _getLogPath();
      final logFile = File(logPath);
      final logDir = logFile.parent;

      // Ensure directory exists
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] $message\n';

      // Append to log file
      logFile.writeAsStringSync(logEntry, mode: FileMode.append);
      print('[nocterm_lints] Logged to file: $logPath');
    } catch (e) {
      // Silently fail - don't interrupt the assist if logging fails
      // But try to at least print the error
      try {
        print('[nocterm_lints] Logging failed: $e');
      } catch (_) {
        // Complete silence if even print fails
      }
    }
  }

  /// Logs a message with context about the file and offset.
  void logAssist(String assistName, String filePath, int offset) {
    final packagePath = _toPackagePath(filePath);
    log('$assistName - File: $packagePath, Offset: $offset');
  }

  /// Logs an error during assist execution.
  void logError(String assistName, String error) {
    log('ERROR in $assistName: $error');
  }
}
