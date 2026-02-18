// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

/// Example of integrating the Nocterm Logger into the analysis server plugin.
///
/// This example shows:
/// 1. How to initialize logging in the plugin
/// 2. How to use logging in assistants
/// 3. Best practices for plugin logging
/// 4. How to avoid breaking the analysis server

// ============================================================================
// In lib/main.dart
// ============================================================================

/*
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:nocterm_lints/assistants/wrap_center.dart';
import 'package:nocterm_lints/utilities/logger.dart';
import 'package:nocterm_lints/utilities/logging_extensions.dart';

final plugin = NoctermPlugin();

class NoctermPlugin extends Plugin {
  @override
  String get name => 'Nocterm Lints';

  @override
  void register(PluginRegistry registry) {
    // Initialize logging at plugin startup
    final logger = NoctermLogger.instance;
    
    try {
      logger.info('Nocterm Plugin initializing...');
      
      // Register all assistants
      _registerAssistants(registry);
      
      logger.info('Nocterm Plugin initialized successfully');
      
      // Flush logs to ensure they're written
      logger.flush();
    } catch (e, st) {
      logger.error('Failed to initialize plugin', e, st);
      logger.flush();
      rethrow;
    }
  }

  void _registerAssistants(PluginRegistry registry) {
    registry.registerAssist(WrapCenter.new);
    registry.registerAssist(WrapColumn.new);
    // ... more registrations
  }
}
*/

// ============================================================================
// In lib/assistants/wrap_center.dart (or any assistant)
// ============================================================================

/*
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:nocterm_lints/services/correction/assist.dart';
import 'package:nocterm_lints/utilities/extensions/nocterm.dart';
import 'package:nocterm_lints/utilities/logging_extensions.dart';

class WrapCenter extends ResolvedCorrectionProducer {
  WrapCenter({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapCenter;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    try {
      logDebug('WrapCenter: Analyzing node at offset $selectionOffset');
      
      final widgetExpr = node.findComponentExpression;
      if (widgetExpr == null) {
        logDebug('WrapCenter: No component expression found');
        return;
      }
      
      logDebug('WrapCenter: Found component at ${widgetExpr.offset}');

      final widgetType = widgetExpr.staticType;
      if (widgetType == null) {
        logWarning('WrapCenter: Could not resolve widget type');
        return;
      }
      
      if (widgetType.isExactComponentTypeCenter) {
        logDebug('WrapCenter: Widget already wrapped in Center, skipping');
        return;
      }

      final widgetSrc = utils.getNodeText(widgetExpr);
      final parentClassElement = await sessionHelper.getClass(
        noctermUri,
        'Center',
      );
      
      if (parentClassElement == null) {
        logError('WrapCenter: Could not resolve Center class');
        return;
      }

      logInfo('WrapCenter: Applying assist for ${widgetExpr.toString()}');
      
      await builder.addDartFileEdit(file, (builder) {
        builder.addReplacement(range.node(widgetExpr), (builder) {
          builder.writeReference(parentClassElement);
          builder.write('(child: ');
          builder.write(widgetSrc);
          builder.write(')');
        });
      });
      
      logInfo('WrapCenter: Assist applied successfully');
    } catch (e, st) {
      logError('WrapCenter: Assist computation failed', e, st);
      rethrow;
    }
  }
}
*/

// ============================================================================
// Configuration Examples
// ============================================================================

/*
// To enable logging during development, set environment variables:

// Option 1: Bash/Zsh
export NOCTERM_LOG_ENABLED=true
export NOCTERM_LOG_LEVEL=debug
export NOCTERM_LOG_DIR=~/.nocterm_logs

// Option 2: In your .env file or IDE configuration
NOCTERM_LOG_ENABLED=true
NOCTERM_LOG_LEVEL=debug
NOCTERM_LOG_DIR=/tmp/nocterm_logs

// Option 3: In VS Code settings.json for the analyzer
"dart.enableSdkFormatter": true,
"[dart]": {
  "editor.defaultFormatter": "Dart-Code.dart-code",
  "editor.formatOnSave": true
}

// Then watch your logs:
tail -f ~/.nocterm_logs/nocterm_lints.log
*/

// ============================================================================
// Best Practices
// ============================================================================

/*
✓ DO:
  1. Log entry/exit of critical methods
  2. Log when decisions affect behavior
  3. Include context (class name, file, offset)
  4. Use appropriate log levels
  5. Flush logs before error exits
  6. Log performance metrics
  7. Include error details (error + stackTrace)

✗ DON'T:
  1. Use print() - breaks analysis server
  2. Log sensitive data (tokens, passwords)
  3. Log in tight loops without buffering
  4. Log full source code
  5. Use debug level in production
  6. Leave logging enabled on release builds
  7. Log at every method call
*/

// ============================================================================
// Performance Monitoring
// ============================================================================

/*
import 'package:nocterm_lints/utilities/logging_extensions.dart';

// Measure assist execution
void exampleMetrics() {
  final startTime = DateTime.now();
  
  // ... perform analysis
  
  final duration = DateTime.now().difference(startTime);
  
  AnalysisMetrics.logAssistExecution(
    'WrapCenter',
    success: true,
    duration: duration,
  );
}
*/

// This file serves as documentation and examples only.
void main() {}
