// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer_plugin/utilities/assist/assist.dart';

/// An enumeration of possible assist kinds.
abstract final class DartAssistKind {
  static const flutterConvertToChildren = AssistKind(
    'dart.assist.nocterm.convert.childToChildren',
    DartAssistKindPriority.default_,
    'Convert to children:',
  );
  static const noctermConvertToStatefulWidget = AssistKind(
    'dart.assist.nocterm.convert.toStatefulComponent',
    DartAssistKindPriority.default_,
    'Convert to StatefulComponent',
  );
  static const noctermConvertToStatelessComponent = AssistKind(
    'dart.assist.nocterm.convert.toStatelessComponent',
    DartAssistKindPriority.default_,
    'Convert to StatelessComponent',
  );
  static const noctermWrapGeneric = AssistKind(
    'dart.assist.nocterm.wrap.generic',
    DartAssistKindPriority.noctermWrapGeneral,
    'Wrap with component...',
  );
  static const noctermWrapBuilder = AssistKind(
    'dart.assist.nocterm.wrap.builder',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Builder',
  );
  static const noctermWrapCenter = AssistKind(
    'dart.assist.nocterm.wrap.center',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Center',
  );
  static const noctermWrapColumn = AssistKind(
    'dart.assist.nocterm.wrap.column',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Column',
  );
  static const noctermWrapContainer = AssistKind(
    'dart.assist.nocterm.wrap.container',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Container',
  );
  static const noctermWrapExpanded = AssistKind(
    'dart.assist.nocterm.wrap.expanded',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Expanded',
  );
  static const noctermWrapFlexible = AssistKind(
    'dart.assist.nocterm.wrap.flexible',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Flexible',
  );

  static const noctermWrapPadding = AssistKind(
    'dart.assist.nocterm.wrap.padding',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Padding',
  );
  static const noctermWrapRow = AssistKind(
    'dart.assist.nocterm.wrap.row',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with Row',
  );
  static const noctermWrapSizedBox = AssistKind(
    'dart.assist.nocterm.wrap.sizedBox',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with SizedBox',
  );

  static const noctermWrapValueListenableBuilder = AssistKind(
    'dart.assist.nocterm.wrap.valueListenableBuilder',
    DartAssistKindPriority.noctermWrapSpecific,
    'Wrap with ValueListenableBuilder',
  );
  static const noctermSwapWithChild = AssistKind(
    'dart.assist.nocterm.swap.withChild',
    DartAssistKindPriority.noctermSwap,
    'Swap with child',
  );
  static const noctermSwapWithParent = AssistKind(
    'dart.assist.nocterm.swap.withParent',
    DartAssistKindPriority.noctermSwap,
    'Swap with parent',
  );
  static const noctermMoveDown = AssistKind(
    'dart.assist.nocterm.move.down',
    DartAssistKindPriority.noctermMove,
    'Move widget down',
  );
  static const noctermMoveUp = AssistKind(
    'dart.assist.nocterm.move.up',
    DartAssistKindPriority.noctermMove,
    'Move widget up',
  );
  static const noctermRemoveWidget = AssistKind(
    'dart.assist.nocterm.removeWidget',
    DartAssistKindPriority.noctermRemove,
    'Remove this widget',
  );
}

/// The priorities associated with various groups of assists.
abstract final class DartAssistKindPriority {
  static const int noctermRemove = 25;
  static const int noctermMove = 26;
  static const int noctermSwap = 27;
  static const int noctermWrapSpecific = 28;
  static const int noctermWrapGeneral = 29;
  static const int default_ = 30;
  static const int priority = 31;
}
