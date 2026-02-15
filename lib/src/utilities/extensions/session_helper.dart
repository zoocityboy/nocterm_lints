import 'package:analyzer/dart/element/element.dart';

/// Returns the class element for the given [className] from the Nocterm
/// package, or `null` if it can't be found.
///
/// This is implemented as a small top-level helper to avoid importing
/// analyzer internal APIs (for example `analysis/session_helper.dart`). The
/// helper accepts the session helper object and forwards the call dynamically.
Future<ClassElement?> getNoctermClass(dynamic sessionHelper, String className) {
  return sessionHelper.getClass(
    'package:nocterm/src/framework/framework.dart',
    className,
  );
}
