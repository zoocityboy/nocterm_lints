import 'package:analyzer/dart/element/element.dart';

/// This file contains some helper methods for
/// getting elements from the analysis
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/session_helper.dart';

import '../logger.dart';

/// Returns the class element for the given [className] from the Nocterm
/// package, or `null` if it can't be found.
///
/// This is implemented as a small top-level helper to avoid importing
/// analyzer internal APIs (for example `analysis/session_helper.dart`). The
/// helper accepts the session helper object and forwards the call dynamically.
Future<ClassElement?> getNoctermClass(
  AnalysisSessionHelper sessionHelper,
  String className,
) {
  NoctermLogger.instance.debug('Looking up Nocterm class: $className');
  final result = sessionHelper.getClass(
    'package:nocterm/src/framework/framework.dart',
    className,
  );

  NoctermLogger.instance.debug('Found Nocterm class: $className');

  return result;
}
