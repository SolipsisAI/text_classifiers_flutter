import 'package:flutter_test/flutter_test.dart';
import 'package:ml_linalg/vector.dart';

import 'package:text_classifiers/text_classifiers.dart';
import 'package:text_classifiers/src/util.dart' as util;

void main() {
  group('util', (() {
    test('softmax', () async {
      final expected = Vector.fromList([1, 2, 3]);
      expect(util.softmax([1, 1, 1]), expected);
    });
  }));
}
