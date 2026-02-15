// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

// import 'package:analysis_server/src/services/correction/assist.dart';
// import 'package:analysis_server/src/services/correction/dart/flutter_swap_with_child.dart';
import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/src/utilities/extensions/flutter.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:nocterm_lints/utilities/extensions/nocterm.dart';

import '../services/correction/assist.dart';
import 'swap_with_child.dart';

class SwapWithParent extends ParentAndChild {
  SwapWithParent({required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermSwapWithParent;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var child = node.findInstanceCreationExpression;
    if (child == null || !child.isComponentCreation) {
      return;
    }
    var parentHadSingleChild = true;

    NamedExpression? namedExpression;
    if (child.parent case ListLiteral listLiteral) {
      if (listLiteral.elements case NodeList(
        length: var length,
      ) when length != 1) {
        return;
      }
      if (listLiteral.parent case NamedExpression parent) {
        namedExpression = parent;
        parentHadSingleChild = false;
      }
    }
    // NamedExpression (child:), ArgumentList, InstanceCreationExpression
    var expr = (namedExpression ?? child.parent)?.parent?.parent;
    if (expr is! InstanceCreationExpression) {
      return;
    }

    await swapParentAndChild(builder, expr, child, parentHadSingleChild);
  }
}
