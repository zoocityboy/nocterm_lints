// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

import 'string.dart';

const _nameAlign = 'Align';
const _nameBuildContext = 'BuildContext';
const _nameBuilder = 'Builder';
const _nameCenter = 'Center';
const _nameContainer = 'Container';
const _nameExpanded = 'Expanded';
const _nameFlex = 'Flex';
const _nameFlexible = 'Flexible';
const _namePadding = 'Padding';
const _nameSizedBox = 'SizedBox';
const _nameState = 'State';
const _nameStatefulComponent = 'StatefulComponent';
const _nameStatelessComponent = 'StatelessComponent';

const _nameComponent = 'Component';

final Uri _widgetsUri = Uri.parse('package:nocterm/nocterm.dart');
final String noctermUri = _widgetsUri.toString();

final Uri _uriAlignment = Uri.parse(
  'package:nocterm/src/components/stack.dart',
);
final Uri _uriBasic = Uri.parse('package:nocterm/src/components/basic.dart');
final Uri _uriContainer = Uri.parse(
  'package:nocterm/src/components/decorated_box.dart',
);

final Uri _uriEdgeInsets = Uri.parse(
  'package:nocterm/src/components/basic.dart',
);
final Uri _uriFramework = Uri.parse(
  'package:nocterm/src/framework/framework.dart',
);
final Uri _uriWidgetsIcon = Uri.parse(
  'package:nocterm/src/components/decorated_box.dart',
);
final Uri _uriWidgetsText = Uri.parse(
  'package:nocterm/src/components/basic.dart',
);

extension AstNodeExtension on AstNode? {
  /// Returns the instance creation expression that surrounds this node, if any,
  /// and otherwise `null`.
  ///
  /// This node may be the instance creation expression itself or an (optionally
  /// prefixed) identifier that names the constructor.
  InstanceCreationExpression? get findInstanceCreationExpression {
    var node = this;
    if (node is ImportPrefixReference) {
      node = node.parent;
    }
    if (node is SimpleIdentifier) {
      node = node.parent;
    }
    if (node is PrefixedIdentifier) {
      node = node.parent;
    }
    if (node is NamedType) {
      node = node.parent;
    }
    if (node is ConstructorName) {
      node = node.parent;
    }
    if (node is InstanceCreationExpression) {
      return node;
    }
    return null;
  }

  /// Attempts to find and return the closest expression that encloses this
  /// and is an independent Nocterm `Component`.
  ///
  /// Returns `null` if nothing is found.
  Expression? get findComponentExpression {
    for (var node = this; node != null; node = node.parent) {
      if (!node.isComponentExpression) {
        if (node is ArgumentList || node is Statement || node is FunctionBody) {
          return null;
        }
        continue;
      }

      if (node is AssignmentExpression) {
        return null;
      }

      final parent = node.parent;

      if (parent is AssignmentExpression) {
        if (parent.rightHandSide == node) {
          return node as Expression;
        }
        return null;
      }

      if (parent is ArgumentList ||
          parent is ConditionalExpression && parent.thenExpression == node ||
          parent is ConditionalExpression && parent.elseExpression == node ||
          parent is ExpressionFunctionBody && parent.expression == node ||
          parent is ForElement && parent.body == node ||
          parent is IfElement && parent.thenElement == node ||
          parent is IfElement && parent.elseElement == node ||
          parent is ListLiteral ||
          parent is NamedExpression && parent.expression == node ||
          parent is Statement ||
          parent is SwitchExpressionCase && parent.expression == node ||
          parent is VariableDeclaration) {
        return node as Expression;
      }
    }
    return null;
  }

  /// Whether this [AstNode] is the Nocterm class `Component`, or its subtype.
  bool get isComponentExpression {
    return switch (this) {
      null => false,
      AstNode(parent: NamedType()) ||
      AstNode(parent: AstNode(parent: NamedType())) => false,
      AstNode(parent: ConstructorName()) => false,
      NamedExpression() => false,
      Expression(:final staticType) => staticType.isComponentType,
      _ => false,
    };
  }

  /// Finds the named expression whose name is the given [name] that is an
  /// argument to a nocterm instance creation expression.
  ///
  /// Returns `null` if this is not a [SimpleIdentifier], or if any other
  /// condition cannot be satisfied.
  NamedExpression? findArgumentNamed(String name) {
    final self = this;
    if (self is! SimpleIdentifier) {
      return null;
    }
    final parent = self.parent;
    final grandParent = parent?.parent;
    if (parent is Label && grandParent is NamedExpression) {
      if (self.name != name) {
        return null;
      }
    } else {
      return null;
    }
    final invocation = grandParent.parent?.parent;
    if (invocation is! InstanceCreationExpression ||
        !invocation.isComponentCreation) {
      return null;
    }
    return grandParent;
  }
}

extension ClassElementExtension2 on ClassElement {
  /// Whether this is the Nocterm class `State`.
  bool get isExactState => _isExactly(_nameState, _uriFramework);

  /// Whether this has the Nocterm class `State` as a superclass.
  bool get isState => _hasSupertype(_uriFramework, _nameState);

  /// Whether this is a [ClassElement] that extends the Nocterm class
  /// `StatefulWidget`.
  bool get isStatefulComponentDeclaration =>
      supertype.isExactlyStatefulComponentType;
}

extension DartTypeExtension on DartType? {
  /// Whether this is the Nocterm type `BuildContext`.
  bool get isBuildContext {
    final self = this;
    return self is InterfaceType &&
        self.nullabilitySuffix == NullabilitySuffix.none &&
        self.element._isExactly(_nameBuildContext, _uriFramework);
  }

  /// Whether this is the 'dart.ui' class `Color`, or a subtype.
  bool get isColor {
    final self = this;
    if (self is! InterfaceType) {
      return false;
    }

    return [self, ...self.element.allSupertypes].any(
      (t) => t.element.name == 'Color' && t.element.library.name == 'dart.ui',
    );
  }

  /// Whether this is the Nocterm type `EdgeInsetsGeometry`.
  bool get isExactEdgeInsetsGeometryType {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly('EdgeInsetsGeometry', _uriEdgeInsets);
  }

  /// Whether this is the Nocterm class `StatefulWidget`.
  bool get isExactlyStatefulComponentType {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameStatefulComponent, _uriFramework);
  }

  /// Whether this is the Nocterm class `StatelessWidget`.
  bool get isExactlyStatelessComponentType {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameStatelessComponent, _uriFramework);
  }

  /// Whether this is the Nocterm class `Align`.
  bool get isExactComponentTypeAlign {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameAlign, _uriBasic);
  }

  /// Whether this is the Nocterm class `Builder`.
  bool get isExactComponentTypeBuilder {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameBuilder, _uriBasic);
  }

  /// Whether this is the Nocterm class `Center`.
  bool get isExactComponentTypeCenter {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameCenter, _uriBasic);
  }

  /// Whether this is the Nocterm class `Container`.
  bool get isExactComponentTypeContainer {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameContainer, _uriContainer);
  }

  /// Whether this is the Nocterm class `Expanded`.
  bool get isExactComponentTypeExpanded {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameExpanded, _uriBasic);
  }

  /// Whether this is the Nocterm class `Flexible`.
  bool get isExactComponentTypeFlexible {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameFlexible, _uriBasic);
  }

  /// Whether this is the Nocterm class `Padding`.
  bool get isExactComponentTypePadding {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_namePadding, _uriBasic);
  }

  /// Whether this is the Nocterm class `SizedBox`.
  bool get isExactComponentTypeSizedBox {
    final self = this;
    return self is InterfaceType &&
        self.element._isExactly(_nameSizedBox, _uriBasic);
  }

  /// Whether this is the Nocterm class `Widget`, or its subtype.
  bool get isListOfWidgetsType {
    final self = this;
    return self is InterfaceType &&
        self.isDartCoreList &&
        self.typeArguments[0].isComponentType;
  }

  /// Whether this is the vector_math_64 class `Matrix4`, or its
  /// subtype.
  bool get isMatrix4 {
    final self = this;
    if (self is! InterfaceType) {
      return false;
    }

    return [self, ...self.element.allSupertypes].any(
      (t) =>
          t.element.name == 'Matrix4' &&
          t.element.library.name == 'vector_math_64',
    );
  }

  /// Whether this is a function type matching the Nocterm typedef
  /// `ComponentBuilder` (i.e., `Component Function(BuildContext context)`).
  bool get isComponentBuilder {
    final self = this;
    return self is FunctionType &&
        self.returnType.isComponentType &&
        self.formalParameters.length == 1 &&
        self.formalParameters[0].type.isBuildContext;
  }

  /// Whether this is the Nocterm class `Component`, or its subtype.
  bool get isComponentType {
    final self = this;
    return self is InterfaceType && self.element.isComponent;
  }
}

extension ExpressionExtension on Expression {
  /// Whether this is the `builder` argument.
  bool get isBuilderArgument {
    final self = this;
    return self is NamedExpression && self.name.label.name == 'builder';
  }

  /// Whether this is the `child` argument.
  bool get isChildArgument {
    final self = this;
    return self is NamedExpression && self.name.label.name == 'child';
  }

  /// Whether this is the `children` argument.
  bool get isChildrenArgument {
    final self = this;
    return self is NamedExpression && self.name.label.name == 'children';
  }
}

extension InstanceCreationExpressionExtension on InstanceCreationExpression {
  /// The named expression representing the `builder` argument, or `null` if
  /// there is none.
  NamedExpression? get builderArgument => argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((argument) => argument.isBuilderArgument);

  /// The named expression representing the `child` argument, or `null` if there
  /// is none.
  NamedExpression? get childArgument => argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((argument) => argument.isChildArgument);

  /// The named expression representing the `children` argument, or `null` if
  /// there is none.
  NamedExpression? get childrenArgument => argumentList.arguments
      .whereType<NamedExpression>()
      .firstWhereOrNull((argument) => argument.isChildrenArgument);

  bool get isExactlyAlignCreation => staticType.isExactComponentTypeAlign;

  bool get isExactlyContainerCreation =>
      staticType.isExactComponentTypeContainer;

  bool get isExactlyPaddingCreation => staticType.isExactComponentTypePadding;

  /// Whether this is a constructor invocation for a class that has the Nocterm
  /// class `Component` as a superclass.
  bool get isComponentCreation {
    final element = constructorName.element?.enclosingElement;
    return element.isComponent;
  }

  /// The presentation for this node.
  String? get widgetPresentationText {
    final element = constructorName.element?.enclosingElement;
    if (!element.isComponent) {
      return null;
    }
    final arguments = argumentList.arguments;
    if (element._isExactly('Icon', _uriWidgetsIcon)) {
      if (arguments.isNotEmpty) {
        final text = arguments[0].toString();
        final arg = text.elideTo(32);
        return 'Icon($arg)';
      } else {
        return 'Icon';
      }
    }
    if (element._isExactly('Text', _uriWidgetsText)) {
      if (arguments.isNotEmpty) {
        final text = arguments[0].toString();
        final arg = text.elideTo(32);
        return 'Text($arg)';
      } else {
        return 'Text';
      }
    }
    return element?.name;
  }
}

extension InterfaceElement2Extension on InterfaceElement? {
  /// Whether this is the Nocterm class `Flex`, or a subtype.
  bool get isFlexWidget {
    final self = this;
    if (self is! ClassElement) {
      return false;
    }
    if (!self.isComponent) {
      return false;
    }
    if (_isExactly(_nameFlex, _uriBasic)) {
      return true;
    }
    return self.allSupertypes.any(
      (type) => type.element._isExactly(_nameFlex, _uriBasic),
    );
  }
}

extension InterfaceElementExtension2 on InterfaceElement? {
  /// Whether this is the Nocterm class `Alignment`.
  bool get isExactAlignment {
    return _isExactly('Alignment', _uriAlignment);
  }

  /// Whether this is the Nocterm class `AlignmentDirectional`.
  bool get isExactAlignmentDirectional {
    return _isExactly('AlignmentDirectional', _uriAlignment);
  }

  /// Whether this is the Nocterm class `AlignmentGeometry`.
  bool get isExactAlignmentGeometry {
    return _isExactly('AlignmentGeometry', _uriAlignment);
  }

  /// Whether this is the Nocterm class `Component`, or a subtype.
  bool get isComponent {
    final self = this;
    if (self is! ClassElement) {
      return false;
    }
    if (_isExactly(_nameComponent, _uriFramework)) {
      return true;
    }
    return self.allSupertypes.any(
      (type) => type.element._isExactly(_nameComponent, _uriFramework),
    );
  }

  /// Whether this has a supertype with the [requiredName] defined in the file
  /// with the [requiredUri].
  bool _hasSupertype(Uri requiredUri, String requiredName) {
    final self = this;
    if (self == null) {
      return false;
    }
    for (final type in self.allSupertypes) {
      if (type.element.name == requiredName) {
        final uri = type.element.library.uri;
        if (uri == requiredUri) {
          return true;
        }
      }
    }
    return false;
  }

  /// Whether this is the exact [type] defined in the file with the given [uri].
  bool _isExactly(String type, Uri uri) {
    final self = this;

    return self is ClassElement && self.name == type && self.library.uri == uri;
  }
}
