// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';
import 'swap_with_child.dart';

class SwapWithParent extends ParentAndChild {
  SwapWithParent({required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermSwapWithParent;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final child = node.findInstanceCreationExpression;
    if (child == null || !child.isComponentCreation) {
      return;
    }
    var parentHadSingleChild = true;

    NamedExpression? namedExpression;
    if (child.parent case final ListLiteral listLiteral) {
      if (listLiteral.elements case NodeList(
        length: final length,
      ) when length != 1) {
        return;
      }
      if (listLiteral.parent case final NamedExpression parent) {
        namedExpression = parent;
        parentHadSingleChild = false;
      }
    }
    // NamedExpression (child:), ArgumentList, InstanceCreationExpression
    final expr = (namedExpression ?? child.parent)?.parent?.parent;
    if (expr is! InstanceCreationExpression) {
      return;
    }

    await swapParentAndChild(builder, expr, child, parentHadSingleChild);
  }
}
