// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

//
// ignore_for_file: non_constant_identifier_names

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/src/correction/dart_change_workspace.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:nocterm_lints/assistants/wrap_builder.dart';
import 'package:nocterm_lints/assistants/wrap_center.dart';
import 'package:nocterm_lints/assistants/wrap_column.dart';
import 'package:nocterm_lints/assistants/wrap_component.dart';
import 'package:nocterm_lints/assistants/wrap_container.dart';
import 'package:nocterm_lints/assistants/wrap_expanded.dart';
import 'package:nocterm_lints/assistants/wrap_flexible.dart';
import 'package:nocterm_lints/assistants/wrap_generic.dart';
import 'package:nocterm_lints/assistants/wrap_padding.dart';
import 'package:nocterm_lints/assistants/wrap_row.dart';
import 'package:nocterm_lints/assistants/wrap_sized_box.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/assist_test_support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(WrapAssistantsTest);
  });
}

const _frameworkStub = '''
abstract class Component {
  const Component({this.child, this.children});
  final Component? child;
  final List<Component>? children;
}

abstract class BuildContext {}

abstract class StatelessComponent extends Component {
  const StatelessComponent({super.child, super.children});
  Component build(BuildContext context);
}

abstract class StatefulComponent extends Component {
  const StatefulComponent({super.child, super.children});
  State createState();
}

abstract class State<T extends StatefulComponent> {
  T get component;
  Component build(BuildContext context);
}
''';

const _basicStub = '''
import '../framework/framework.dart';

class Text extends Component {
  const Text(String value);
}

class Flex extends Component {
  const Flex({required super.children});
}

class Row extends Flex {
  const Row({required super.children});
}

class Column extends Flex {
  const Column({required super.children});
}

class Center extends Component {
  const Center({required super.child});
}

class Builder extends Component {
  const Builder({required Component Function(BuildContext) builder});
}

class Expanded extends Component {
  const Expanded({required super.child});
}

class Flexible extends Component {
  const Flexible({required super.child});
}

class EdgeInsetsGeometry {
  const EdgeInsetsGeometry();
}

class EdgeInsets extends EdgeInsetsGeometry {
  const EdgeInsets.all(num value);
}

class Padding extends Component {
  const Padding({required EdgeInsetsGeometry padding, required super.child});
}

class SizedBox extends Component {
  const SizedBox({required super.child});
}

class ValueListenableBuilder extends Component {
  const ValueListenableBuilder({
    required Object valueListenable,
    required Component Function(BuildContext, Object?, Component?) builder,
  });
}
''';

const _decoratedBoxStub = '''
import '../framework/framework.dart';

class Container extends Component {
  const Container({required super.child});
}
''';

@reflectiveTest
class WrapAssistantsTest extends AssistTestBase {
  @override
  void setUp() {
    registerPackage('nocterm')
      ..addFile('lib/nocterm.dart', """
export 'src/framework/framework.dart';
export 'src/components/basic.dart';
export 'src/components/decorated_box.dart';
""")
      ..addFile('lib/src/framework/framework.dart', _frameworkStub)
      ..addFile('lib/src/components/basic.dart', _basicStub)
      ..addFile('lib/src/components/decorated_box.dart', _decoratedBoxStub);
    super.setUp();
  }

  Future<void> test_wrapBuilder_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapBuilder(context: context),
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Builder('));
    expect(result, contains('builder: (context)'));
  }

  Future<void> test_wrapBuilder_negative_alreadyBuilder() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Builder(builder: (context) {
      return Text('x');
    });
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapBuilder(context: context),
      offsetToken: 'Builder(builder:',
    );

    expect(change, isNull);
  }

  Future<void> test_wrapValueListenableBuilder_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) =>
          WrapValueListenableBuilder(context: context),
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('ValueListenableBuilder('));
    expect(result, contains('valueListenable: valueListenable'));
    expect(result, contains('builder: (context, value, child)'));
  }

  Future<void> test_wrapValueListenableBuilder_negative_nonComponent() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

void f() {
  final n = 1;
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) =>
          WrapValueListenableBuilder(context: context),
      offsetToken: 'n = 1',
    );

    expect(change, isNull);
  }

  Future<void> test_wrapCenter_positive() async {
    await _expectSingleWrapPositive(
      producerFactory: ({required context}) => WrapCenter(context: context),
      wrapperName: 'Center(',
    );
  }

  Future<void> test_wrapCenter_negative_alreadyWrapped() async {
    await _expectSingleWrapNegativeAlreadyWrapped(
      producerFactory: ({required context}) => WrapCenter(context: context),
      wrappedExpr: "Center(child: Text('x'))",
      offsetToken: 'Center(child:',
    );
  }

  Future<void> test_wrapContainer_positive() async {
    await _expectSingleWrapPositive(
      producerFactory: ({required context}) => WrapContainer(context: context),
      wrapperName: 'Container(',
    );
  }

  Future<void> test_wrapContainer_negative_alreadyWrapped() async {
    await _expectSingleWrapNegativeAlreadyWrapped(
      producerFactory: ({required context}) => WrapContainer(context: context),
      wrappedExpr: "Container(child: Text('x'))",
      offsetToken: 'Container(child:',
    );
  }

  Future<void> test_wrapExpanded_positive() async {
    await _expectSingleWrapPositive(
      producerFactory: ({required context}) => WrapExpanded(context: context),
      wrapperName: 'Expanded(',
    );
  }

  Future<void> test_wrapExpanded_negative_alreadyWrapped() async {
    await _expectSingleWrapNegativeAlreadyWrapped(
      producerFactory: ({required context}) => WrapExpanded(context: context),
      wrappedExpr: "Expanded(child: Text('x'))",
      offsetToken: 'Expanded(child:',
    );
  }

  Future<void> test_wrapFlexible_positive() async {
    await _expectSingleWrapPositive(
      producerFactory: ({required context}) => WrapFlexible(context: context),
      wrapperName: 'Flexible(',
    );
  }

  Future<void> test_wrapFlexible_negative_alreadyWrapped() async {
    await _expectSingleWrapNegativeAlreadyWrapped(
      producerFactory: ({required context}) => WrapFlexible(context: context),
      wrappedExpr: "Flexible(child: Text('x'))",
      offsetToken: 'Flexible(child:',
    );
  }

  Future<void> test_wrapPadding_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapPadding(context: context),
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Padding('));
    expect(result, contains('padding: const EdgeInsets.all('));
    expect(result, contains("child: Text('x')"));
  }

  Future<void> test_wrapPadding_negative_alreadyWrapped() async {
    await _expectSingleWrapNegativeAlreadyWrapped(
      producerFactory: ({required context}) => WrapPadding(context: context),
      wrappedExpr:
          "Padding(padding: const EdgeInsets.all(8), child: Text('x'))",
      offsetToken: 'Padding(padding:',
    );
  }

  Future<void> test_wrapSizedBox_positive() async {
    await _expectSingleWrapPositive(
      producerFactory: ({required context}) => WrapSizedBox(context: context),
      wrapperName: 'SizedBox(',
    );
  }

  Future<void> test_wrapSizedBox_negative_alreadyWrapped() async {
    await _expectSingleWrapNegativeAlreadyWrapped(
      producerFactory: ({required context}) => WrapSizedBox(context: context),
      wrappedExpr: "SizedBox(child: Text('x'))",
      offsetToken: 'SizedBox(child:',
    );
  }

  Future<void> test_wrapGeneric_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapGeneric(context: context),
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('component('));
    expect(result, contains("child: Text('x')"));
  }

  Future<void> test_wrapGeneric_negative_nonComponent() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

void f() {
  final value = 10;
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapGeneric(context: context),
      offsetToken: 'value = 10',
    );

    expect(change, isNull);
  }

  Future<void> test_wrapRow_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapRow(context: context),
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Row('));
    expect(result, contains('children: ['));
  }

  Future<void> test_wrapRow_negative_nonComponent() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

void f() {
  final value = 10;
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapRow(context: context),
      offsetToken: 'value = 10',
    );

    expect(change, isNull);
  }

  Future<void> test_wrapColumn_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapColumn(context: context),
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Column('));
    expect(result, contains('children: ['));
  }

  Future<void> test_wrapColumn_negative_nonComponent() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

void f() {
  final value = 10;
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapColumn(context: context),
      offsetToken: 'value = 10',
    );

    expect(change, isNull);
  }

  Future<void> test_wrapComponent_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

final items = [
  Text('a'),
  Text('b'),
];
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapComponent(context: context),
      offsetToken: "[\n  Text('a')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('component('));
    expect(result, contains('children: ['));
  }

  Future<void> test_wrapComponent_negative_nonComponentInList() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

final items = [
  Text('a'),
  1,
];
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => WrapComponent(context: context),
      offsetToken: "[\n  Text('a')",
    );

    expect(change, isNull);
  }

  Future<void> _expectSingleWrapPositive({
    required _ProducerFactory producerFactory,
    required String wrapperName,
  }) async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Text('x');
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: producerFactory,
      offsetToken: "Text('x')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains(wrapperName));
    expect(result, contains("child: Text('x')"));
  }

  Future<void> _expectSingleWrapNegativeAlreadyWrapped({
    required _ProducerFactory producerFactory,
    required String wrappedExpr,
    required String offsetToken,
  }) async {
    final code =
        '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return $wrappedExpr;
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: producerFactory,
      offsetToken: offsetToken,
    );

    expect(change, isNull);
  }

  Future<SourceChange?> _computeSourceChange(
    String code, {
    required _ProducerFactory producerFactory,
    required String offsetToken,
    String fileName = 'test.dart',
  }) async {
    final filePath = convertPath('$testPackageLib/$fileName');
    newFile(filePath, code);

    final unitResult = await resolveFile(filePath);
    final session = unitResult.session;
    final libraryResult =
        await session.getResolvedLibrary(filePath) as ResolvedLibraryResult;

    final selectionOffset = code.indexOf(offsetToken);
    expect(selectionOffset, isNot(-1));

    final context = CorrectionProducerContext.createResolved(
      libraryResult: libraryResult,
      unitResult: unitResult,
      selectionOffset: selectionOffset,
    );

    final workspace = DartChangeWorkspace([session]);
    final builder = ChangeBuilder(workspace: workspace, defaultEol: '\n');

    final producer = producerFactory(context: context);
    await producer.compute(builder);

    final change = builder.sourceChange;
    return change.edits.isEmpty ? null : change;
  }

  String _applyEdits(String originalCode, SourceChange change) {
    var result = originalCode;
    for (final fileEdit in change.edits) {
      final sortedEdits = [...fileEdit.edits]
        ..sort((a, b) => b.offset.compareTo(a.offset));
      result = SourceEdit.applySequence(result, sortedEdits);
    }
    return result;
  }
}

typedef _ProducerFactory =
    ResolvedCorrectionProducer Function({
      required CorrectionProducerContext context,
    });
