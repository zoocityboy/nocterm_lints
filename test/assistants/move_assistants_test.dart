// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

// This file is a part of nocterm_lints.
// ignore_for_file: non_constant_identifier_names

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/src/correction/dart_change_workspace.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:nocterm_lints/assistants/move_down.dart';
import 'package:nocterm_lints/assistants/move_up.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/assist_test_support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MoveAssistantsTest);
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

class Column extends Component {
  const Column({required super.children});
}
''';

@reflectiveTest
class MoveAssistantsTest extends AssistTestBase {
  @override
  void setUp() {
    registerPackage('nocterm')
      ..addFile(
        'lib/nocterm.dart',
        """
export 'src/framework/framework.dart';
export 'src/components/basic.dart';
s""",
      )
      ..addFile('lib/src/framework/framework.dart', _frameworkStub)
      ..addFile('lib/src/components/basic.dart', _basicStub);
    super.setUp();
  }

  Future<void> test_moveUp_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(children: [
      Text('a'),
      Text('b'),
      Text('c'),
    ]);
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => MoveUp(context: context),
      offsetToken: "Text('b')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result.indexOf("Text('b')") < result.indexOf("Text('a')"), isTrue);
  }

  Future<void> test_moveUp_negative_firstItem() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(children: [
      Text('a'),
      Text('b'),
    ]);
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => MoveUp(context: context),
      offsetToken: "Text('a')",
    );

    expect(change, isNull);
  }

  Future<void> test_moveDown_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(children: [
      Text('a'),
      Text('b'),
      Text('c'),
    ]);
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => MoveDown(context: context),
      offsetToken: "Text('a')",
    );

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result.indexOf("Text('b')") < result.indexOf("Text('a')"), isTrue);
  }

  Future<void> test_moveDown_negative_lastItem() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(children: [
      Text('a'),
      Text('b'),
    ]);
  }
}
''';
    final change = await _computeSourceChange(
      code,
      producerFactory: ({required context}) => MoveDown(context: context),
      offsetToken: "Text('b')",
    );

    expect(change, isNull);
  }

  Future<SourceChange?> _computeSourceChange(
    String code, {
    required ResolvedCorrectionProducer Function({
      required CorrectionProducerContext context,
    })
    producerFactory,
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
