// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';

/// Wraps a component with SizedBox.
class WrapSizedBox extends ResolvedCorrectionProducer {
  WrapSizedBox({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapSizedBox;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final widgetExpr = node.findComponentExpression;
    if (widgetExpr == null) {
      return;
    }

    final widgetType = widgetExpr.staticType;
    if (widgetType == null || widgetType.isExactComponentTypeSizedBox) {
      return;
    }

    final widgetSrc = utils.getNodeText(widgetExpr);
    final parentClassElement = await sessionHelper.getClass(
      noctermUri,
      'SizedBox',
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
