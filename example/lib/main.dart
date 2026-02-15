import 'package:nocterm/nocterm.dart';

void main() {
  // Example app that uses the package's analysis settings.
  // Run `dart analyze` in this `example/` directory to see lints/assists.
  runApp(
    NoctermApp(
      title: 'Nocterm Lints Example',
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Run `dart analyze` to see lints/assists.'),
          Text('This is an example app for nocterm_lints.'),
        ],
      ),
    ),
  );
}

class SampleScreen extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Container(child: Text('It is not used in the main app.')),
        ),
        Center(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('This is a sample screen.'),
            ),
          ),
        ),
      ],
    );
  }
}

class MyDataPage extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Text('Current value: 42');
  }
}
