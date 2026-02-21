// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/src/correction/dart_change_workspace.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:nocterm_lints/assistants/swap_with_child.dart';
import 'package:nocterm_lints/assistants/swap_with_parent.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/assist_test_support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SwapAssistantsTest);
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
''';

const _basicStub = '''
import '../framework/framework.dart';

class Text extends Component {
  const Text(String value);
}

class Center extends Component {
  const Center({required super.child});
}

class Container extends Component {
  const Container({required super.child});
}

class Column extends Component {
  const Column({required super.children});
}

class Empty extends Component {
  const Empty();
}
''';

@reflectiveTest
class SwapAssistantsTest extends AssistTestBase {
  @override
  void setUp() {
    registerPackage('nocterm')
      ..addFile(
        'lib/nocterm.dart',
        "export 'src/framework/framework.dart';"
        "export 'src/components/basic.dart';",
      )
      ..addFile('lib/src/framework/framework.dart', _frameworkStub)
      ..addFile('lib/src/components/basic.dart', _basicStub);
    super.setUp();
  }

  Future<void> test_swapWithChild_positive_childArgument() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('x'),
      ),
    );
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => SwapWithChild(context: context),
      offsetToken: 'Center(',
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Container('));
    expect(result, contains('child: Center('));
  }

  Future<void> test_swapWithChild_positive_childrenSingle() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text('x')),
      ],
    );
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => SwapWithChild(context: context),
      offsetToken: 'Column(',
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Center('));
    expect(result, contains('child: Column('));
  }

  Future<void> test_swapWithChild_negative_noChild() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Empty();
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => SwapWithChild(context: context),
      offsetToken: 'Empty()',
    );

    expect(change, isNull);
  }

  Future<void> test_swapWithParent_positive_childArgument() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('x'),
      ),
    );
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => SwapWithParent(context: context),
      offsetToken: 'Container(',
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Container('));
    expect(result, contains('child: Center('));
  }

  Future<void> test_swapWithParent_positive_childrenSingle() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text('x')),
      ],
    );
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => SwapWithParent(context: context),
      offsetToken: 'Center(',
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains('Center('));
    expect(result, contains('child: Column('));
  }

  Future<void> test_swapWithParent_negative_childrenMultiple() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text('a')),
        Container(child: Text('b')),
      ],
    );
  }
}
''';

    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => SwapWithParent(context: context),
      offsetToken: 'Center(',
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
