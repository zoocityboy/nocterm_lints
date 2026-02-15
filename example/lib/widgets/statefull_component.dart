import 'package:nocterm/nocterm.dart';

class StatefulComponentX extends StatefulComponent {
  @override
  State<StatefulComponentX> createState() => _StatefulComponentXState();
}

class _StatefulComponentXState extends State<StatefulComponentX> {
  @override
  Component build(BuildContext context) {
    return Container(child: Text('This is a stateful component.'));
  }
}
