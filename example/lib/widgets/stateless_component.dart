import 'package:nocterm/nocterm.dart';

class StatelessComponentX extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Container(child: Text('This is a stateless component.'));
  }
}
