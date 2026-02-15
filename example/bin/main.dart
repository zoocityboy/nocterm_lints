void main() {
  // Demo wrappable component expression
  // Hover over 'Container' or 'Text' to see nocterm_lints assists
  // Assists available:
  //   - Wrap with Widget
  //   - Wrap with Padding
  //   - Wrap with Center
  //   - Wrap with Row
  //   - Wrap with Column
  //
  myComponent();
}

// A function returning a wrappable component expression
Object myComponent() {
  return Container();
}

// Example: wrap this Text widget
Object textExample() {
  return Text('Hello World');
}

// Placeholder Component classes for demonstration
class Container {
  Container({this.child});
  final Object? child;
}

class Text {
  Text(this.data, {this.child});
  final String data;
  final Object? child;
}

class Padding {
  Padding({required this.child});
  final Object child;
}

class Center {
  Center({required this.child});
  final Object child;
}

class Row {
  Row({this.children = const []});
  final List<Object> children;
}

class Column {
  Column({this.children = const []});
  final List<Object> children;
}
