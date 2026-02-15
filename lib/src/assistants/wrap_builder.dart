// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer/src/dart/element/type.dart';
import '../utilities/extensions/nocterm.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';

abstract class _BaseWrapBuilder extends ResolvedCorrectionProducer {
  final List<String> extraBuilderParams;
  final List<String> extraNamedParams;
  final String builderName;

  _BaseWrapBuilder({
    required super.context,
    required this.builderName,
    required this.extraNamedParams,
    required this.extraBuilderParams,
  });

  @override
  CorrectionApplicability get applicability =>
      // TODO(applicability): comment on why.
      CorrectionApplicability.singleLocation;

  bool canWrapOn(TypeImpl typeOrThrow) {
    return !typeOrThrow.isExactComponentTypeBuilder;
  }

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var widgetExpr = node.findComponentExpression;
    if (widgetExpr == null) {
      return;
    }
    if (!canWrapOn(widgetExpr.typeOrThrow)) {
      return;
    }
    var widgetSrc = utils.getNodeText(widgetExpr);

    var builderElement = await sessionHelper.getFlutterClass(builderName);
    if (builderElement == null) {
      return;
    }

    var params = ['context', ...extraBuilderParams];

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(widgetExpr), (builder) {
        builder.writeReference(builderElement);

        builder.writeln('(');

        var indentOld = utils.getLinePrefix(widgetExpr.offset);
        var indentNew1 = indentOld + utils.oneIndent;
        var indentNew2 = indentOld + utils.twoIndents;

        var namedParams = extraNamedParams.join(', ');

        if (namedParams.isNotEmpty) {
          builder.write(indentNew1);
          builder.write('$namedParams: ');
          builder.addSimpleLinkedEdit('variable', namedParams);
          builder.writeln(',');
        }

        builder.write(indentNew1);
        builder.writeln('builder: (${params.join(', ')}) {');

        widgetSrc = utils.replaceSourceIndent(widgetSrc, indentOld, indentNew2);
        builder.write(indentNew2);
        builder.write('return $widgetSrc');
        builder.writeln(';');

        builder.write(indentNew1);
        var addTrailingCommas = getCodeStyleOptions(
          unitResult.file,
        ).addTrailingCommas;
        builder.writeln('}${addTrailingCommas ? "," : ""}');

        builder.write(indentOld);
        builder.write(')');
      });
    });
  }
}

class WrapBuilder extends _BaseWrapBuilder {
  WrapBuilder({required super.context})
    : super(
        builderName: 'Builder',
        extraNamedParams: const [],
        extraBuilderParams: const [],
      );

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapBuilder;
}

class WrapValueListenableBuilder extends _BaseWrapBuilder {
  WrapValueListenableBuilder({required super.context})
    : super(
        builderName: 'ValueListenableBuilder',
        extraNamedParams: const ['valueListenable'],
        extraBuilderParams: const ['value', 'child'],
      );

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapValueListenableBuilder;
}
