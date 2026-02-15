// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../services/correction/selection_analyzer.dart';
import '../utilities/extensions/nocterm.dart';

/// Wraps multiple components with Column.
class WrapColumn extends ResolvedCorrectionProducer {
  WrapColumn({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapColumn;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final selectionRange = SourceRange(selectionOffset, selectionLength);
    final analyzer = SelectionAnalyzer(selectionRange);
    unitResult.unit.accept(analyzer);

    final widgetExpressions = _extractSelectedWidgetExpressions(analyzer);
    if (widgetExpressions.isEmpty) {
      return;
    }

    final firstWidget = widgetExpressions.first;
    final lastWidget = widgetExpressions.last;
    final selectedRange = range.startEnd(firstWidget, lastWidget);
    final src = utils.getRangeText(selectedRange);

    final parentClassElement = await sessionHelper.getClass(
      noctermUri,
      'Column',
    );
    if (parentClassElement == null) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(selectedRange, (builder) {
        builder.writeReference(parentClassElement);
        builder.write('(');

        final indentOld = utils.getLinePrefix(firstWidget.offset);
        final indentNew1 = indentOld + utils.oneIndent;
        final indentNew2 = indentOld + utils.twoIndents;

        builder.writeln();
        builder.write(indentNew1);
        builder.write('children: [');
        builder.writeln();

        final newSrc = utils.replaceSourceIndent(src, indentOld, indentNew2);
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
    final widgetExpressions = <Expression>[];

    if (analyzer.hasSelectedNodes) {
      for (var selectedNode in analyzer.selectedNodes) {
        final parent = selectedNode.parent;
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

      final widget = coveringNode.findComponentExpression;
      if (widget != null) {
        widgetExpressions.add(widget);
      }
    }

    return widgetExpressions;
  }
}
