// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../utilities/extensions/nocterm.dart';

abstract class ParentAndChild extends ResolvedCorrectionProducer {
  ParentAndChild({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  Future<void> swapParentAndChild(
    ChangeBuilder builder,
    InstanceCreationExpression parent,
    InstanceCreationExpression child,
    bool parentHadSingleChild,
  ) async {
    // Find the expression that corresponds to the child.
    NamedExpression? childArgumentInParent;
    for (final arg in parent.argumentList.arguments) {
      if (arg is NamedExpression && arg.expression == child) {
        childArgumentInParent = arg;
        break;
      }
    }

    // The child must have its own single child.
    AstNode stableChild;
    if (_singleChildInChildren(child) case final first?) {
      stableChild = first;
    } else if (child.childArgument case final childArgument?) {
      stableChild = childArgument;
    } else {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(range.node(parent), (builder) {
        final childArgs = child.argumentList;
        final parentArgs = parent.argumentList;
        final childText = utils.getRangeText(
          range.startStart(child, childArgs),
        );
        final parentText = utils.getRangeText(
          range.startStart(parent, parentArgs),
        );

        final parentIndent = utils.getLinePrefix(parent.offset);
        final childIndent = '$parentIndent  ';

        // Write the beginning of the child.
        builder.write(childText);
        builder.writeln('(');

        // Write all the arguments of the parent.
        // Don't write the "child".
        for (final argument in childArgs.arguments) {
          if (argument != stableChild) {
            var text = utils.getNodeText(argument);
            text = utils.replaceSourceIndent(text, childIndent, parentIndent);
            builder.write(parentIndent);
            builder.write('  ');
            builder.write(text);
            builder.writeln(',');
          }
        }

        // Write the parent as a new child.
        builder.write(parentIndent);
        builder.write('  ');
        builder.write('child: ');
        builder.write(parentText);
        builder.writeln('(');

        // Write all arguments of the parent.
        // Don't write its child/children.
        for (final argument in parentArgs.arguments) {
          if (argument != childArgumentInParent && !argument.isChildArgument) {
            var text = utils.getNodeText(argument);
            text = utils.replaceSourceIndent(text, parentIndent, childIndent);
            builder.write(childIndent);
            builder.write('  ');
            builder.write(text);
            builder.writeln(',');
          }
        }

        {
          var text = utils.getNodeText(stableChild);
          if (text.trim().startsWith('child: ')) {
            text = text.substring('child: '.length);
          } else if (text.trim().startsWith('children: ')) {
            text = text.substring('children: '.length);
          }
          builder.write(childIndent);
          builder.write('  ');
          if (parentHadSingleChild) {
            if (childArgumentInParent != null) {
              builder.write(childArgumentInParent.name.label.name);
              builder.write(': ');
            } else {
              builder.write('child: ');
            }
          } else {
            builder.write('children: [');
            builder.writeln();
            builder.write(childIndent);
            builder.write('    ');
          }
          builder.write(text);
          builder.writeln(',');
        }

        // Close the parent expression.
        builder.write(childIndent);
        if (!parentHadSingleChild) {
          builder.write('  ');
          builder.write(']');
          builder.writeln(',');
          builder.write(childIndent);
        }
        builder.writeln('),');

        // Close the child expression.
        builder.write(parentIndent);
        builder.write(')');
      });
    });
  }

  InstanceCreationExpression? _singleChildInChildren(
    InstanceCreationExpression parent,
  ) {
    if (parent.childrenArgument case final childrenArgument?) {
      if (childrenArgument.expression case final ListLiteral list) {
        if (list.elements case NodeList(length: 1, first: final first)) {
          if (first is InstanceCreationExpression) {
            return first;
          }
        }
      }
    }
    return null;
  }
}

class SwapWithChild extends ParentAndChild {
  SwapWithChild({required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermSwapWithChild;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final parent = node.findInstanceCreationExpression;
    if (parent == null || !parent.isComponentCreation) {
      return;
    }
    var parentHasSingleChild = true;

    Expression? child;
    if (_singleChildInChildren(parent) case final first?) {
      child = first;
      parentHasSingleChild = false;
    }
    child ??= parent.childArgument?.expression;
    if (child is! InstanceCreationExpression || !child.isComponentCreation) {
      return;
    }

    await swapParentAndChild(builder, parent, child, parentHasSingleChild);
  }
}
