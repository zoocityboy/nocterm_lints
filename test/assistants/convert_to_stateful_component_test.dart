// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/src/correction/dart_change_workspace.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:nocterm_lints/assistants/convert_to_stateful_component.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/assist_test_support.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConvertToStatefulComponentTest);
  });
}

/// Stub source for the `nocterm` framework. Only declares the minimal surface
/// needed for [ConvertToStatefulComponent] to resolve type checks
/// (`isExactlyStatelessComponentType`, `isExactState`, etc.).
const _frameworkStub = '''
abstract class Component {
  const Component({Object? key});
}

abstract class BuildContext {}

abstract class StatelessComponent extends Component {
  const StatelessComponent({Object? key}) : super(key: key);
  Component build(BuildContext context);
}

abstract class StatefulComponent extends Component {
  const StatefulComponent({Object? key}) : super(key: key);
  State createState();
}

abstract class State<T extends StatefulComponent> {
  T get component;
  Component build(BuildContext context);
  void setState(void Function() fn) {}
  void initState() {}
  void dispose() {}
}
''';

@reflectiveTest
class ConvertToStatefulComponentTest extends AssistTestBase {
  @override
  void setUp() {
    // Register the nocterm stub before calling super.setUp() so the package
    // config is written with it included.
    registerPackage('nocterm')
      ..addFile('lib/nocterm.dart', "export 'src/framework/framework.dart';")
      ..addFile('lib/src/framework/framework.dart', _frameworkStub);
    super.setUp();
  }

  // ---------------------------------------------------------------------------
  // Success cases – assist should be produced
  // ---------------------------------------------------------------------------

  Future<void> test_simpleStatelessComponent_producesAssist() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Component();
  }
}
''';
    final change = await _computeSourceChange(
      code,
      offsetToken: 'class MyComponent',
    );

    expect(change, isNotNull, reason: 'Assist should produce a change');
    final result = _applyEdits(code, change!);
    expect(result, contains('extends StatefulComponent'));
    expect(result, isNot(contains('extends StatelessComponent')));
    expect(result, contains('createState()'));
    expect(result, contains('_MyComponentState'));
    expect(result, contains('extends State<MyComponent>'));
    expect(result, contains('Component build(BuildContext context)'));
  }

  Future<void> test_statelessWithField_movesFieldToState() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class Counter extends StatelessComponent {
  final String label = 'hello';

  @override
  Component build(BuildContext context) {
    return Component();
  }
}
''';
    final change = await _computeSourceChange(
      code,
      offsetToken: 'class Counter',
    );

    expect(change, isNotNull, reason: 'Assist should produce a change');
    final result = _applyEdits(code, change!);
    expect(result, contains('extends StatefulComponent'));
    expect(result, contains('createState()'));
    expect(result, contains('_CounterState'));
    expect(result, contains("final String label = 'hello'"));
    expect(result, isNot(contains('extends StatelessComponent')));
  }

  // ---------------------------------------------------------------------------
  // Failure cases – assist should NOT be produced
  // ---------------------------------------------------------------------------

  Future<void> test_alreadyStatefulComponent_noAssist() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class MyComponent extends StatefulComponent {
  @override
  State createState() => _MyComponentState();
}

class _MyComponentState extends State<MyComponent> {
  @override
  Component build(BuildContext context) {
    return Component();
  }
}
''';
    final change = await _computeSourceChange(
      code,
      offsetToken: 'class MyComponent',
    );

    expect(change, isNull, reason: 'Already stateful – no assist expected');
  }

  Future<void> test_noBuildMethod_noAssist() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class MyComponent extends StatelessComponent {}
''';
    final change = await _computeSourceChange(
      code,
      offsetToken: 'class MyComponent',
    );

    expect(change, isNull, reason: 'No build method – no assist expected');
  }

  Future<void> test_selectionOutsideClassHeader_noAssist() async {
    const code = '''
import 'package:nocterm/nocterm.dart';

class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Component();
  }
}
''';
    // Place cursor inside the build method body – outside the class header
    // trigger zone (class keyword … opening brace).
    final change = await _computeSourceChange(
      code,
      offsetToken: 'return Component',
    );

    expect(
      change,
      isNull,
      reason: 'Cursor is outside class header – no assist',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Runs [ConvertToStatefulComponent.compute] at [offsetToken] in [code] and
  /// returns the resulting [SourceChange], or `null` if the assist produced no
  /// edits.
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
    expect(
      selectionOffset,
      isNot(-1),
      reason: 'offsetToken "$offsetToken" not found in code',
    );

    final context = CorrectionProducerContext.createResolved(
      libraryResult: libraryResult,
      unitResult: unitResult,
      selectionOffset: selectionOffset,
    );

    final workspace = DartChangeWorkspace([session]);
    final builder = ChangeBuilder(
      workspace: workspace,
      defaultEol: '\n',
    );

    final producer = ConvertToStatefulComponent(context: context);
    await producer.compute(builder);

    final change = builder.sourceChange;
    return change.edits.isEmpty ? null : change;
  }

  /// Applies all [SourceFileEdit]s from [change] to [originalCode] and returns
  /// the transformed source string.
  ///
  /// Edits are applied from highest to lowest offset so that earlier offsets
  /// are not invalidated by later insertions/replacements.
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
