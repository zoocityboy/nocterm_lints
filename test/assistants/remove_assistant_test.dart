// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/src/correction/dart_change_workspace.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:nocterm_lints/assistants/remove_widget.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/assist_test_support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RemoveAssistantTest);
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

class Column extends Component {
  const Column({required super.children});
}

class Builder extends Component {
  const Builder({required Component Function(BuildContext) builder});
}
''';

@reflectiveTest
class RemoveAssistantTest extends AssistTestBase {
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

  Future<void> test_remove_child_positive() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Center(child: Text('x'));
  }
}
''';

    final change = await _computeSourceChange(code, offsetToken: 'Center(');

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains("return Text('x');"));
    expect(result, isNot(contains('Center(')));
  }

  Future<void> test_remove_children_positive_singleParentExpression() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(children: [Text('x')]);
  }
}
''';

    final change = await _computeSourceChange(code, offsetToken: 'Column(');

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains("return Text('x');"));
    expect(result, isNot(contains('Column(')));
  }

  Future<void> test_remove_children_negative_multipleOutsideList() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Column(children: [Text('a'), Text('b')]);
  }
}
''';

    final change = await _computeSourceChange(code, offsetToken: 'Column(');

    expect(change, isNull);
  }

  Future<void> test_remove_whenInList_positive_deletesEntry() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

final list = [
  Text('a'),
  Center(child: Text('b')),
  Text('c'),
];
''';

    final change = await _computeSourceChange(code, offsetToken: 'Center(');

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, isNot(contains("Center(child: Text('b'))")));
    expect(result, contains("Text('a')"));
    expect(result, contains("Text('c')"));
  }

  Future<void> test_remove_builder_positive_unusedContext() async {
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

    final change = await _computeSourceChange(code, offsetToken: 'Builder(');

    expect(change, isNotNull);
    final result = _applyEdits(code, change!);
    expect(result, contains("return Text('x');"));
    expect(result, isNot(contains('Builder(')));
  }

  Future<void> test_remove_builder_negative_contextUsed() async {
    const code = r'''
import 'package:nocterm/nocterm.dart';

class A extends StatelessComponent {
  const A();

  @override
  Component build(BuildContext context) {
    return Builder(builder: (context) {
      final ctx = context;
      return Text('$ctx');
    });
  }
}
''';

    final change = await _computeSourceChange(code, offsetToken: 'Builder(');

    expect(change, isNull);
  }

  Future<void> test_remove_negative_nonComponentNode() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

void f() {
  final n = 1;
}
''';

    final change = await _computeSourceChange(code, offsetToken: 'n = 1');

    expect(change, isNull);
  }

  Future<SourceChange?> _computeSourceChange(
    String code, {
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

    final producer = RemoveWidget(context: context);
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
