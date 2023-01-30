import 'package:flutter_test/flutter_test.dart';
import 'package:ml_linalg/vector.dart';
import 'package:mockito/annotations.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite_flutter;

import 'package:text_classifiers/text_classifiers.dart';

import 'text_classifiers_test.mocks.dart';

@GenerateMocks([tflite_flutter.Interpreter])
void main() {
  group('classifier io', (() {}));
}
