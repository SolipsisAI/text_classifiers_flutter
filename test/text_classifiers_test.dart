import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite_flutter;

import 'package:text_classifiers/text_classifiers.dart';

import 'text_classifiers_test.mocks.dart';

@GenerateMocks([tflite_flutter.Interpreter])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('classifier', (() {
    test('loads model from assets', () async {
      const vocabFile = 'vocab.txt';
      const modelFile = 'model.tflite';
      final classifier = Classifier(vocabFile, modelFile);
    });
  }));
}
