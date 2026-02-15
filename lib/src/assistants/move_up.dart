// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';

class MoveUp extends ResolvedCorrectionProducer {
  MoveUp({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermMoveUp;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final widget = node.findComponentExpression;
    if (widget == null) {
      return;
    }

    final parentList = widget.parent;
    if (parentList is ListLiteral) {
      final List<CollectionElement> parentElements = parentList.elements;
      final index = parentElements.indexOf(widget);
      if (index > 0) {
        await builder.addDartFileEdit(file, (fileBuilder) {
          final previousWidget = parentElements[index - 1];
          final previousRange = range.node(previousWidget);
          final previousText = utils.getRangeText(previousRange);

          final widgetRange = range.node(widget);
          final widgetText = utils.getRangeText(widgetRange);

          fileBuilder.addSimpleReplacement(previousRange, widgetText);
          fileBuilder.addSimpleReplacement(widgetRange, previousText);

          final newWidgetOffset = previousRange.offset;
          builder.setSelection(Position(file, newWidgetOffset));
        });
      }
    }
  }
}
