// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// Wraps a component with a generic 'component' placeholder.
class NoctermWrapGeneric extends ResolvedCorrectionProducer {
  NoctermWrapGeneric({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapGeneric;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var widgetExpr = node.findComponentExpression;
    if (widgetExpr == null) {
      return;
    }

    var widgetSrc = utils.getNodeText(widgetExpr);

    await builder.addDartFileEdit(file, (builder) {
      var eol = builder.eol;
      builder.addReplacement(range.node(widgetExpr), (builder) {
        builder.addSimpleLinkedEdit('COMPONENT', 'component');
        builder.write('(');
        builder.selectHere();
        var leadingLines = <String>[];
        if (widgetSrc.contains(eol) || leadingLines.isNotEmpty) {
          var indentOld = utils.getLinePrefix(widgetExpr.offset);
          var indentNew = '$indentOld${utils.oneIndent}';

          for (var leadingLine in leadingLines) {
            builder.writeln();
            builder.write(indentNew);
            builder.write(leadingLine);
          }

          builder.writeln();
          builder.write(indentNew);
          widgetSrc = utils.replaceSourceIndent(
            widgetSrc,
            indentOld,
            indentNew,
          );
          widgetSrc += ',$eol$indentOld';
        }
        builder.addSimpleLinkedEdit('CHILD', 'child');
        builder.write(': ');
        builder.write(widgetSrc);
        builder.write(')');
      });
    });
  }
}
