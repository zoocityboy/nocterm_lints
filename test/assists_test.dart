import 'package:nocterm_lints/src/assists.dart';
import 'package:test/test.dart';

void main() {
  group('Nocterm Assists', () {
    test('WrapWithWidget is defined', () {
      expect(WrapWithWidget, isNotNull);
    });

    test('WrapWithPadding is defined', () {
      expect(WrapWithPadding, isNotNull);
    });

    test('WrapWithCenter is defined', () {
      expect(WrapWithCenter, isNotNull);
    });

    test('WrapWithRow is defined', () {
      expect(WrapWithRow, isNotNull);
    });

    test('WrapWithColumn is defined', () {
      expect(WrapWithColumn, isNotNull);
    });

    test('RemoveComponent is defined', () {
      expect(RemoveComponent, isNotNull);
    });

    test('SwapWithChild is defined', () {
      expect(SwapWithChild, isNotNull);
    });

    test('SwapWithParent is defined', () {
      expect(SwapWithParent, isNotNull);
    });

    // TODO: Add integration tests using analyzer_testing framework
    // See .github/instructions/analysis-server-plugin.instructions.md
    // for testing guidelines using AnalysisRuleTest and test_reflective_loader
  });
}
