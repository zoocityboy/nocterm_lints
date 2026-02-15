// Copyright (c) 2020, the Dart project authors.
// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import '../services/correction/assist.dart';
import '../services/correction/selection_analyzer.dart';
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import '../utilities/extensions/nocterm.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

/// Coordinates registration of wrap-based code assists for Nocterm components.
///
/// This producer discovers eligible components and registers appropriate
/// wrap assists (Center, Container, Padding, Row, Column, etc.) based on
/// the component type and context.
class NoctermWrap extends MultiCorrectionProducer {
  NoctermWrap({required super.context});

  @override
  Future<List<ResolvedCorrectionProducer>> get producers async {
    var producers = <ResolvedCorrectionProducer>[];
    var widgetExpr = node.findComponentExpression;
    if (widgetExpr == null) {
      return producers;
    }

    try {
      var widgetType = widgetExpr.typeOrThrow;

      // Always provide generic wrap option
      _registerProducer(
        producers,
        NoctermWrapGeneric(widgetExpr, context: context),
      );

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
      _registerProducer(
        producers,
        NoctermWrapCenter(widgetExpr, context: context),
      );
    }

    // Container wrap
    if (!widgetType.isExactComponentTypeContainer) {
      _registerProducer(
        producers,
        NoctermWrapContainer(widgetExpr, context: context),
      );
    }

    // Expanded wrap (flex context only)
    if (!widgetType.isExactComponentTypeExpanded &&
        (widgetExpr.isParentFlexWidget || !widgetExpr.isParentWidget)) {
      _registerProducer(
        producers,
        NoctermWrapExpanded(widgetExpr, context: context),
      );
    }

    // Flexible wrap (flex context only)
    if (!widgetType.isExactComponentTypeFlexible &&
        (widgetExpr.isParentFlexWidget || !widgetExpr.isParentWidget)) {
      _registerProducer(
        producers,
        NoctermWrapFlexible(widgetExpr, context: context),
      );
    }

    // Padding wrap
    if (!widgetType.isExactComponentTypePadding) {
      _registerProducer(
        producers,
        NoctermWrapPadding(widgetExpr, context: context),
      );
    }

    // SizedBox wrap
    if (!widgetType.isExactComponentTypeSizedBox) {
      _registerProducer(
        producers,
        NoctermWrapSizedBox(widgetExpr, context: context),
      );
    }
  }

  /// Register wrap assistants for multi-widget operations (Row, Column).
  Future<void> _registerMultiWidgetWrappers(
    List<ResolvedCorrectionProducer> producers,
  ) async {
    var selectionRange = SourceRange(selectionOffset, selectionLength);
    var analyzer = SelectionAnalyzer(selectionRange);
    unitResult.unit.accept(analyzer);

    var widgetExpressions = _extractSelectedWidgetExpressions(analyzer);
    if (widgetExpressions.isEmpty) {
      return;
    }

    var firstWidget = widgetExpressions.first;
    var lastWidget = widgetExpressions.last;

    _registerProducer(
      producers,
      NoctermWrapColumn(firstWidget, lastWidget, context: context),
    );
    _registerProducer(
      producers,
      NoctermWrapRow(firstWidget, lastWidget, context: context),
    );
  }

  /// Extract component expressions from analyzer selection.
  List<Expression> _extractSelectedWidgetExpressions(
    SelectionAnalyzer analyzer,
  ) {
    var widgetExpressions = <Expression>[];

    if (analyzer.hasSelectedNodes) {
      for (var selectedNode in analyzer.selectedNodes) {
        // If the user has selected exactly a Widget constructor name (without
        // the argument list), expand the selection.
        //
        //    Text('foo')
        //   [^^^^]
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

      // If the coveringNode is an argument list but the caret is exactly at the
      // start (before the opening paren) we should use the parent instead
      // as the user associates this location with the widget name:
      //
      //     Text^('foo')
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
// through NoctermWrap. Each assistant handles transforming Nocterm components
// by wrapping them with layout or spacing widgets.
//
// SINGLE-WIDGET WRAPPERS (applied to individual components):
//   - NoctermWrapGeneric  : Wrap with generic 'component' placeholder
//   - NoctermWrapCenter   : Wrap with Center alignment widget
//   - NoctermWrapContainer: Wrap with Container decoration widget
//   - NoctermWrapExpanded : Wrap with Expanded (flex only)
//   - NoctermWrapFlexible : Wrap with Flexible (flex only)
//   - NoctermWrapPadding  : Wrap with Padding edge insets
//   - NoctermWrapSizedBox : Wrap with SizedBox size constraints
//
// MULTI-WIDGET WRAPPERS (applied to multiple selected components):
//   - NoctermWrapRow      : Wrap selection with Row (horizontal layout)
//   - NoctermWrapColumn   : Wrap selection with Column (vertical layout)
//
// ============================================================================

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapCenter extends _WrapSingleWidget {
  NoctermWrapCenter(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapCenter;

  @override
  String get _parentClassName => 'Center';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapColumn extends _WrapMultipleWidgets {
  NoctermWrapColumn(
    super.firstWidget,
    super.lastWidget, {
    required super.context,
  });

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapColumn;

  @override
  String get _parentClassName => 'Column';
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapContainer extends _WrapSingleWidget {
  NoctermWrapContainer(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapContainer;

  @override
  String get _parentClassName => 'Container';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapExpanded extends _WrapSingleWidget {
  NoctermWrapExpanded(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapExpanded;

  @override
  String get _parentClassName => 'Expanded';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapFlexible extends _WrapSingleWidget {
  NoctermWrapFlexible(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapFlexible;

  @override
  String get _parentClassName => 'Flexible';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapGeneric extends _WrapSingleWidget {
  NoctermWrapGeneric(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapGeneric;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapPadding extends _WrapSingleWidget {
  NoctermWrapPadding(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapPadding;

  @override
  List<String> get _leadingLines {
    var keyword = widgetExpr.inConstantContext ? '' : ' const';
    var codeStyleOptions = getCodeStyleOptions(unitResult.file);
    var paddingStr = codeStyleOptions.preferIntLiterals ? '8' : '8.0';
    return ['padding:$keyword EdgeInsets.all($paddingStr),'];
  }

  @override
  String get _parentClassName => 'Padding';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapRow extends _WrapMultipleWidgets {
  NoctermWrapRow(super.firstWidget, super.lastWidget, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapRow;

  @override
  String get _parentClassName => 'Row';
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
class NoctermWrapSizedBox extends _WrapSingleWidget {
  NoctermWrapSizedBox(super.widgetExpr, {required super.context});

  @override
  AssistKind get assistKind => DartAssistKind.noctermWrapSizedBox;

  @override
  String get _parentClassName => 'SizedBox';

  @override
  String get _parentLibraryUri => noctermUri;
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
abstract class _WrapMultipleWidgets extends ResolvedCorrectionProducer {
  final Expression firstWidget;

  final Expression lastWidget;

  _WrapMultipleWidgets(
    this.firstWidget,
    this.lastWidget, {
    required super.context,
  });

  @override
  CorrectionApplicability get applicability =>
      // TODO(applicability): comment on why.
      CorrectionApplicability.singleLocation;

  String get _parentClassName;

  String get _parentLibraryUri => noctermUri;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    var selectedRange = range.startEnd(firstWidget, lastWidget);
    var src = utils.getRangeText(selectedRange);
    var parentClassElement = await sessionHelper.getClass(
      _parentLibraryUri,
      _parentClassName,
    );
    var widgetClassElement = await sessionHelper.getFlutterClass('Widget');
    if (parentClassElement == null || widgetClassElement == null) {
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
}

/// A correction processor that can make one of the possible changes computed by
/// the [NoctermWrap] producer.
abstract class _WrapSingleWidget extends ResolvedCorrectionProducer {
  final Expression widgetExpr;

  _WrapSingleWidget(this.widgetExpr, {required super.context});

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
    var parentLibraryUri = _parentLibraryUri;
    var parentClassName = _parentClassName;
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
      var eol = builder.eol;
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
        var leadingLines = _leadingLines;
        if (widgetSrc.contains(eol) || leadingLines.isNotEmpty) {
          var indentOld = utils.getLinePrefix(widgetExpr.offset);
          var indentNew = '$indentOld${utils.oneIndent}';

          for (var leadingLine in leadingLines) {
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
    var parent = _getParentInstanceCreationExpression();
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
    var parent = _getParentInstanceCreationExpression();
    return parent != null && parent.isComponentCreation;
  }

  /// Return the parent `InstanceCreationExpression` if it exists.
  ///
  /// This is used to find the parent widget creation if it exists.
  InstanceCreationExpression? _getParentInstanceCreationExpression() {
    var self = this;
    NamedExpression? namedExpression;
    if (self.parent case ListLiteral listLiteral) {
      if (listLiteral.parent case NamedExpression parent) {
        namedExpression = parent;
      }
    }
    // NamedExpression (child:), ArgumentList, InstanceCreationExpression
    if ((namedExpression ?? self.parent)?.parent?.parent
        case InstanceCreationExpression parent?) {
      return parent;
    }
    return null;
  }
}

extension on DartType? {
  bool get isComponentFlexType {
    var self = this;
    return self is InterfaceType && self.element.isFlexWidget;
  }
}
