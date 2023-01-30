import 'package:flutter_test/flutter_test.dart';

import 'package:text_classifiers/text_classifiers.dart';

void main() {
  test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 4);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
