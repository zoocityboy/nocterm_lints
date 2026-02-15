// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import '../services/correction/assist.dart';
import '../services/correction/selection_analyzer.dart';
import '../utilities/extensions/nocterm.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// Wraps multiple components with Row.
class NoctermWrapRow extends ResolvedCorrectionProducer {
  NoctermWrapRow({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapRow;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var selectionRange = SourceRange(selectionOffset, selectionLength);
    var analyzer = SelectionAnalyzer(selectionRange);
    unitResult.unit.accept(analyzer);

    var widgetExpressions = _extractSelectedWidgetExpressions(analyzer);
    if (widgetExpressions.isEmpty) {
      return;
    }

    var firstWidget = widgetExpressions.first;
    var lastWidget = widgetExpressions.last;
    var selectedRange = range.startEnd(firstWidget, lastWidget);
    var src = utils.getRangeText(selectedRange);

    var parentClassElement = await sessionHelper.getClass(noctermUri, 'Row');
    if (parentClassElement == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(selectedRange, (builder) {
        builder.writeReference(parentClassElement);
        builder.write('(');

        var indentOld = utils.getLinePrefix(firstWidget.offset);
        var indentNew1 = indentOld + utils.oneIndent;
        var indentNew2 = indentOld + utils.twoIndents;

        builder.writeln();
        builder.write(indentNew1);
        builder.write('children: [');
        builder.writeln();

        var newSrc = utils.replaceSourceIndent(src, indentOld, indentNew2);
        builder.write(indentNew2);
        builder.write(newSrc);

        builder.write(',');
        builder.writeln();

        builder.write(indentNew1);
        builder.write('],');
        builder.writeln();

        builder.write(indentOld);
        builder.write(')');
      });
    });
  }

  List<Expression> _extractSelectedWidgetExpressions(
    SelectionAnalyzer analyzer,
  ) {
    var widgetExpressions = <Expression>[];

    if (analyzer.hasSelectedNodes) {
      for (var selectedNode in analyzer.selectedNodes) {
        var parent = selectedNode.parent;
        if (selectedNode is ConstructorName &&
            parent is InstanceCreationExpression) {
          selectedNode = parent;
        }
        if (selectedNode is! Expression ||
            !selectedNode.isComponentExpression) {
          return widgetExpressions;
        }
        widgetExpressions.add(selectedNode);
      }
    } else {
      var coveringNode = analyzer.coveringNode;

      if (coveringNode is ArgumentList &&
          coveringNode.offset == selectionOffset) {
        coveringNode = coveringNode.parent;
      }

      var widget = coveringNode.findComponentExpression;
      if (widget != null) {
        widgetExpressions.add(widget);
      }
    }

    return widgetExpressions;
  }
}
