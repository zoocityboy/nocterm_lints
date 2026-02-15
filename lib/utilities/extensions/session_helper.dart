import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/analysis/session_helper.dart';

extension SessionHelperExtension on AnalysisSessionHelper {
  /// Returns the class element for the given [className] from the Nocterm
  /// package, or `null` if it can't be found.
  Future<ClassElement?> getNoctermClass(String className) =>
      getClass('package:nocterm/nocterm.dart', className);
}
