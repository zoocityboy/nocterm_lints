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

class Nocterm extends StatefulComponent {
  const Nocterm({Key? key}) : super(key: key);

  @override
  State<Nocterm> createState() => _NoctermState();
}

class _NoctermState extends State<Nocterm> {
  @override
  Component build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
