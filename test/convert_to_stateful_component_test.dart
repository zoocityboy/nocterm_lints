import 'package:nocterm_lints/assistants/convert_to_stateful_component.dart';
import 'package:nocterm_lints/assistants/convert_to_stateless_component.dart';
import 'package:nocterm_lints/services/correction/assist.dart';
import 'package:test/test.dart';

void main() {
  group('ConvertToStatefulComponent', () {
    test('assist is defined', () {
      expect(ConvertToStatefulWidget, isNotNull);
    });

    test('assist kind is correct', () {
      const assistKind = DartAssistKind.noctermConvertToStatefulWidget;
      expect(assistKind.id, 'dart.assist.nocterm.convert.toStatefulComponent');
      expect(assistKind.message, 'Convert to StatefulComponent');
    });
  });

  group('ConvertToStatelessComponent', () {
    test('assist is defined', () {
      expect(ConvertToStatelessWidget, isNotNull);
    });

    test('assist kind is correct', () {
      const assistKind = DartAssistKind.noctermConvertToStatelessComponent;
      expect(assistKind.id, 'dart.assist.nocterm.convert.toStatelessComponent');
      expect(assistKind.message, 'Convert to StatelessComponent');
    });
  });
}
