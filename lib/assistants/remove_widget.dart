// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';

class RemoveWidget extends ResolvedCorrectionProducer {
  RemoveWidget({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermRemoveWidget;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final widgetCreation = node.findInstanceCreationExpression;
    if (widgetCreation == null || !widgetCreation.isComponentCreation) {
      return;
    }

    if (widgetCreation.childrenArgument case final childrenArgument?) {
      final childrenExpression = childrenArgument.expression;
      if (childrenExpression is ListLiteral &&
          childrenExpression.elements.isNotEmpty) {
        await _removeChildren(
          builder,
          widgetCreation,
          childrenExpression.elements,
        );
      }
    } else if (widgetCreation.childArgument case final childArgument?) {
      await _removeSingle(builder, widgetCreation, childArgument.expression);
    } else if (widgetCreation.builderArgument case final builderArgument?) {
      await _removeBuilder(builder, widgetCreation, builderArgument);
    } else {
      await _removeSingleWhenInList(builder, widgetCreation);
    }
  }

  Future<void> _removeBuilder(
    ChangeBuilder builder,
    InstanceCreationExpression widgetCreation,
    NamedExpression builderArgument,
  ) async {
    final builderExpression = builderArgument.expression;
    if (builderExpression is! FunctionExpression) return;
    final parameterElement = builderExpression
        .parameters
        ?.parameters
        .firstOrNull
        ?.declaredFragment
        ?.element;
    if (parameterElement == null) return;

    final visitor = _UsageFinder(parameterElement);
    final body = builderExpression.body;
    body.visitChildren(visitor);
    if (visitor.used) return;

    if (body is BlockFunctionBody) {
      final statements = body.block.statements;
      if (statements.length != 1) return;
      final statement = statements.first;
      if (statement is! ReturnStatement) return;
      final expression = statement.expression;
      if (expression == null) return;
      await _removeSingle(builder, widgetCreation, expression);
    } else if (body is ExpressionFunctionBody) {
      await _removeSingle(builder, widgetCreation, body.expression);
    }
  }

  Future<void> _removeChildren(
    ChangeBuilder builder,
    InstanceCreationExpression widgetCreation,
    List<CollectionElement> childrenExpressions,
  ) async {
    // We can inline the list of our children only into another list.
    final widgetParentNode = widgetCreation.parent;
    if (childrenExpressions.length > 1 && widgetParentNode is! ListLiteral) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      final firstChild = childrenExpressions.first;
      final lastChild = childrenExpressions.last;
      var childText = utils.getRangeText(range.startEnd(firstChild, lastChild));
      final indentOld = utils.getLinePrefix(firstChild.offset);
      final indentNew = utils.getLinePrefix(widgetCreation.offset);
      childText = utils.replaceSourceIndent(childText, indentOld, indentNew);
      builder.addSimpleReplacement(range.node(widgetCreation), childText);
    });
  }

  Future<void> _removeSingle(
    ChangeBuilder builder,
    InstanceCreationExpression widgetCreation,
    Expression expression,
  ) async {
    await builder.addDartFileEdit(file, (builder) {
      var childText = utils.getNodeText(expression);
      final indentOld = utils.getLinePrefix(expression.offset);
      final indentNew = utils.getLinePrefix(widgetCreation.offset);
      childText = utils.replaceSourceIndent(childText, indentOld, indentNew);
      builder.addSimpleReplacement(range.node(widgetCreation), childText);
    });
  }

  Future<void> _removeSingleWhenInList(
    ChangeBuilder builder,
    InstanceCreationExpression widgetCreation,
  ) async {
    // We can only remove the widget when this widget is in list.
    final widgetParentNode = widgetCreation.parent;
    if (widgetParentNode is! ListLiteral) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(
        range.nodeInList(widgetParentNode.elements, widgetCreation),
      );
    });
  }
}

class _UsageFinder extends RecursiveAstVisitor<void> {
  _UsageFinder(this.element);
  final Element element;
  bool used = false;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.writeOrReadElement == element) {
      used = true;
    }
  }
}
