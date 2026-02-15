// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// Wraps a component with Flexible (for flex contexts only).
class WrapFlexible extends ResolvedCorrectionProducer {
  WrapFlexible({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapFlexible;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var widgetExpr = node.findComponentExpression;
    if (widgetExpr == null) {
      return;
    }

    var widgetType = widgetExpr.staticType;
    if (widgetType == null || widgetType.isExactComponentTypeFlexible) {
      return;
    }

    var widgetSrc = utils.getNodeText(widgetExpr);
    var parentClassElement = await sessionHelper.getClass(
      noctermUri,
      'Flexible',
    );
    if (parentClassElement == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      // var eol = builder.eol;
      builder.addReplacement(range.node(widgetExpr), (builder) {
        builder.writeReference(parentClassElement);
        builder.write('(child: ');
        builder.write(widgetSrc);
        builder.write(')');
      });
    });
  }
}
