// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import '../services/correction/assist.dart';
import '../services/correction/selection_analyzer.dart';
import '../utilities/extensions/nocterm.dart';

/// Coordinates registration of wrap-based code assists for Nocterm components.
///
/// This producer discovers eligible components and registers appropriate
/// wrap assists (Center, Container, Padding, Row, Column, etc.) based on
/// the component type and context.
class Wrap extends MultiCorrectionProducer {
  Wrap({required super.context});

  @override
  Future<List<ResolvedCorrectionProducer>> get producers async {
    final producers = <ResolvedCorrectionProducer>[];
    final widgetExpr = node.findComponentExpression;
    if (widgetExpr == null) {
      return producers;
    }

    try {
      final widgetType = widgetExpr.typeOrThrow;

      // Always provide generic wrap option
      _registerProducer(producers, WrapGeneric(widgetExpr, context: context));

      // Register single-widget wrapper assistants
      _registerSingleWidgetWrappers(producers, widgetExpr, widgetType);

      // Register multi-widget wrapper assistants
      await _registerMultiWidgetWrappers(producers);
    } catch (e) {
      // If type analysis fails, return gracefully with at least generic wrap
      return producers;
    }

    return producers;
  }

  /// Register wrap assistants for single-widget operations.
  void _registerSingleWidgetWrappers(
    List<ResolvedCorrectionProducer> producers,
    Expression widgetExpr,
    DartType widgetType,
  ) {
    // Center wrap
    if (!widgetType.isExactComponentTypeCenter) {
      _registerProducer(producers, WrapCenter(widgetExpr, context: context));
    }

    // Container wrap
    if (!widgetType.isExactComponentTypeContainer) {
      _registerProducer(producers, WrapContainer(widgetExpr, context: context));
    }

    // Expanded wrap (flex context only)
    if (!widgetType.isExactComponentTypeExpanded &&
        (widgetExpr.isParentFlexWidget || !widgetExpr.isParentWidget)) {
      _registerProducer(producers, WrapExpanded(widgetExpr, context: context));
    }

    // Flexible wrap (flex context only)
    if (!widgetType.isExactComponentTypeFlexible &&
        (widgetExpr.isParentFlexWidget || !widgetExpr.isParentWidget)) {
      _registerProducer(producers, WrapFlexible(widgetExpr, context: context));
    }

    // Padding wrap
    if (!widgetType.isExactComponentTypePadding) {
      _registerProducer(producers, WrapPadding(widgetExpr, context: context));
    }

    // SizedBox wrap
    if (!widgetType.isExactComponentTypeSizedBox) {
      _registerProducer(producers, WrapSizedBox(widgetExpr, context: context));
    }
  }

  /// Register wrap assistants for multi-widget operations (Row, Column).
  Future<void> _registerMultiWidgetWrappers(
    List<ResolvedCorrectionProducer> producers,
  ) async {
    final selectionRange = SourceRange(selectionOffset, selectionLength);
    final analyzer = SelectionAnalyzer(selectionRange);
    unitResult.unit.accept(analyzer);

    final widgetExpressions = _extractSelectedWidgetExpressions(analyzer);
    if (widgetExpressions.isEmpty) {
      return;
    }

    final firstWidget = widgetExpressions.first;
    final lastWidget = widgetExpressions.last;

    _registerProducer(
      producers,
      WrapColumn(firstWidget, lastWidget, context: context),
    );
    _registerProducer(
      producers,
      WrapRow(firstWidget, lastWidget, context: context),
    );
  }

  /// Extract component expressions from analyzer selection.
  List<Expression> _extractSelectedWidgetExpressions(
    SelectionAnalyzer analyzer,
  ) {
    final widgetExpressions = <Expression>[];

    if (analyzer.hasSelectedNodes) {
      for (var selectedNode in analyzer.selectedNodes) {
        // If the user has selected exactly a Widget constructor name (without
        // the argument list), expand the selection.
        //
        //    Text('foo')
        //   [^^^^]
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

      // If the coveringNode is an argument list but the caret is exactly at the
      // start (before the opening paren) we should use the parent instead
      // as the user associates this location with the widget name:
      //
      //     Text^('foo')
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

  /// Register a producer with diagnostic tracking.
  void _registerProducer(
    List<ResolvedCorrectionProducer> producers,
    ResolvedCorrectionProducer producer,
  ) {
    producers.add(producer);
  }
}

// ============================================================================
// REGISTERED WRAP ASSISTANTS
// ============================================================================
//
// The following classes represent all wrap-based code assists registered
// through Wrap. Each assistant handles transforming Nocterm components
// by wrapping them with layout or spacing widgets.
//
// SINGLE-WIDGET WRAPPERS (applied to individual components):
//   - WrapGeneric  : Wrap with generic 'component' placeholder
//   - WrapCenter   : Wrap with Center alignment widget
//   - WrapContainer: Wrap with Container decoration widget
//   - WrapExpanded : Wrap with Expanded (flex only)
//   - WrapFlexible : Wrap with Flexible (flex only)
//   - WrapPadding  : Wrap with Padding edge insets
//   - WrapSizedBox : Wrap with SizedBox size constraints
//
// MULTI-WIDGET WRAPPERS (applied to multiple selected components):
//   - WrapRow      : Wrap selection with Row (horizontal layout)
//   - WrapColumn   : Wrap selection with Column (vertical layout)
//
// ============================================================================

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapCenter extends _WrapSingleWidget {
  WrapCenter(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapCenter;

  @override
  String get _parentClassName => 'Center';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapColumn extends _WrapMultipleWidgets {
  WrapColumn(super.firstWidget, super.lastWidget, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapColumn;

  @override
  String get _parentClassName => 'Column';
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapContainer extends _WrapSingleWidget {
  WrapContainer(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapContainer;

  @override
  String get _parentClassName => 'Container';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapExpanded extends _WrapSingleWidget {
  WrapExpanded(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapExpanded;

  @override
  String get _parentClassName => 'Expanded';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapFlexible extends _WrapSingleWidget {
  WrapFlexible(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapFlexible;

  @override
  String get _parentClassName => 'Flexible';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapGeneric extends _WrapSingleWidget {
  WrapGeneric(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapGeneric;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapPadding extends _WrapSingleWidget {
  WrapPadding(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapPadding;

  @override
  List<String> get _leadingLines {
    final keyword = widgetExpr.inConstantContext ? '' : ' const';
    final codeStyleOptions = getCodeStyleOptions(unitResult.file);
    final paddingStr = codeStyleOptions.preferIntLiterals ? '8' : '8.0';
    return ['padding:$keyword EdgeInsets.all($paddingStr),'];
  }

  @override
  String get _parentClassName => 'Padding';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapRow extends _WrapMultipleWidgets {
  WrapRow(super.firstWidget, super.lastWidget, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapRow;

  @override
  String get _parentClassName => 'Row';
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
class WrapSizedBox extends _WrapSingleWidget {
  WrapSizedBox(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapSizedBox;

  @override
  String get _parentClassName => 'SizedBox';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
abstract class _WrapMultipleWidgets extends ResolvedCorrectionProducer {
  _WrapMultipleWidgets(
    this.firstWidget,
    this.lastWidget, {
    required super.context,
  });
  final Expression firstWidget;

  final Expression lastWidget;

  @override
  CorrectionApplicability get applicability =>
      // TODO(applicability): comment on why.
      CorrectionApplicability.singleLocation;

  String get _parentClassName;

  String get _parentLibraryUri => noctermUri;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final selectedRange = range.startEnd(firstWidget, lastWidget);
    final src = utils.getRangeText(selectedRange);
    final parentClassElement = await sessionHelper.getClass(
      _parentLibraryUri,
      _parentClassName,
    );
    final widgetClassElement = await sessionHelper.getFlutterClass('Widget');
    if (parentClassElement == null || widgetClassElement == null) {
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
}

/// A correction processor that can make one of the possible changes computed by
/// the [Wrap] producer.
abstract class _WrapSingleWidget extends ResolvedCorrectionProducer {
  _WrapSingleWidget(this.widgetExpr, {required super.context});
  final Expression widgetExpr;

  @override
  CorrectionApplicability get applicability =>
      // TODO(applicability): comment on why.
      CorrectionApplicability.singleLocation;

  List<String> get _leadingLines => const [];

  String? get _parentClassName => null;

  String? get _parentLibraryUri => null;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var widgetSrc = utils.getNodeText(widgetExpr);

    // If the wrapper class is specified, find its element.
    final parentLibraryUri = _parentLibraryUri;
    final parentClassName = _parentClassName;
    ClassElement? parentClassElement;
    if (parentLibraryUri != null && parentClassName != null) {
      parentClassElement = await sessionHelper.getClass(
        parentLibraryUri,
        parentClassName,
      );
      if (parentClassElement == null) {
        return;
      }
    }

    await builder.addDartFileEdit(file, (builder) {
      final eol = builder.eol;
      builder.addReplacement(range.node(widgetExpr), (builder) {
        if (parentClassElement == null) {
          builder.addSimpleLinkedEdit('COMPONENT', 'component');
        } else {
          builder.writeReference(parentClassElement);
        }
        builder.write('(');
        // When there's no linked edit for the widget name, leave the selection
        // inside the opening paren which is useful if you want to add
        // additional named arguments to the newly-created widget.
        if (parentClassElement != null) {
          builder.selectHere();
        }
        final leadingLines = _leadingLines;
        if (widgetSrc.contains(eol) || leadingLines.isNotEmpty) {
          final indentOld = utils.getLinePrefix(widgetExpr.offset);
          final indentNew = '$indentOld${utils.oneIndent}';

          for (final leadingLine in leadingLines) {
            builder.writeln();
            builder.write(indentNew);
            builder.write(leadingLine);
          }

          builder.writeln();
          builder.write(indentNew);
          widgetSrc = utils.replaceSourceIndent(
            widgetSrc,
            indentOld,
            indentNew,
          );
          widgetSrc += ',$eol$indentOld';
        }
        if (parentClassElement == null) {
          builder.addSimpleLinkedEdit('CHILD', 'child');
        } else {
          builder.write('child');
        }
        builder.write(': ');
        builder.write(widgetSrc);
        builder.write(')');
      });
    });
  }
}

extension on Expression {
  /// Return `true` if the parent is a `Flex` widget creation.
  ///
  /// This is used to determine if the widget is wrapped in a `Row`, `Column`,
  /// or `Flex` widget.
  bool get isParentFlexWidget {
    final parent = _getParentInstanceCreationExpression();
    if (parent == null || !parent.isComponentCreation) {
      return false;
    }
    return parent.staticType.isComponentFlexType;
  }

  /// Return `true` if the parent is a widget creation.
  ///
  /// This tells if this is a direct child of a widget creation.
  /// It will return `false` if we are assigning this to a variable or
  /// returning it from a function or other similar cases.
  bool get isParentWidget {
    final parent = _getParentInstanceCreationExpression();
    return parent != null && parent.isComponentCreation;
  }

  /// Return the parent `InstanceCreationExpression` if it exists.
  ///
  /// This is used to find the parent widget creation if it exists.
  InstanceCreationExpression? _getParentInstanceCreationExpression() {
    final self = this;
    NamedExpression? namedExpression;
    if (self.parent case final ListLiteral listLiteral) {
      if (listLiteral.parent case final NamedExpression parent) {
        namedExpression = parent;
      }
    }
    // NamedExpression (child:), ArgumentList, InstanceCreationExpression
    if ((namedExpression ?? self.parent)?.parent?.parent
        case final InstanceCreationExpression parent?) {
      return parent;
    }
    return null;
  }
}

extension on DartType? {
  bool get isComponentFlexType {
    final self = this;
    return self is InterfaceType && self.element.isFlexWidget;
  }
}
