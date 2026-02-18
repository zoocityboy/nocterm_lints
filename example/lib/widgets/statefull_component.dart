import 'package:nocterm/nocterm.dart';

class StatefulComponentX extends StatefulComponent {
  @override
  State<StatefulComponentX> createState() => _StatefulComponentXState();
}

class _StatefulComponentXState extends State<StatefulComponentX>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Component build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Container(child: Text('This is a stateful component.')),
        );
      },
    );
  }
}
