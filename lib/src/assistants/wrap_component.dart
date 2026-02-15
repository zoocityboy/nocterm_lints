// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/src/utilities/extensions/string_extension.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';

class WrapComponent extends ResolvedCorrectionProducer {
  WrapComponent({required super.context});

  @override
  CorrectionApplicability get applicability =>
      // TODO(applicability): comment on why.
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapGeneric;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node is! ListLiteral) {
      return;
    }
    if ((node as ListLiteral).elements.any(
      (element) =>
          !(element is InstanceCreationExpression &&
              element.isComponentCreation),
    )) {
      return;
    }
    final eol = unitResult.content.endOfLine ?? builder.defaultEol;
    final literalSrc = utils.getNodeText(node);
    final newlineIdx = literalSrc.lastIndexOf(eol);
    if (newlineIdx < 0 || newlineIdx == literalSrc.length - 1) {
      return; // Lists need to be in multi-line format already.
    }
    final indentOld = utils.getLinePrefix(
      node.offset + eol.length + newlineIdx,
    );
    final indentArg = '$indentOld${utils.oneIndent}';
    final indentList = '$indentOld${utils.twoIndents}';

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(node), (builder) {
        builder.write('[');
        builder.write(eol);
        builder.write(indentArg);
        builder.addSimpleLinkedEdit('COMPONENT', 'component');
        builder.write('(');
        builder.write(eol);
        builder.write(indentList);
        // Linked editing not needed since arg is always a list.
        builder.write('children: ');
        builder.write(
          utils.replaceSourceIndent(literalSrc, indentOld, indentList),
        );
        builder.write(',');
        builder.write(eol);
        builder.write(indentArg);
        builder.write('),');
        builder.write(eol);
        builder.write(indentOld);
        builder.write(']');
      });
    });
  }
}
