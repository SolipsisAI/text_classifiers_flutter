import 'package:tflite_flutter/tflite_flutter.dart';

import 'classifier.dart';

const vocabFile = 'sentiment_classification.vocab.txt';
const modelFile = 'sentiment_classification.tflite';
const int sentenceLen = 256;
const String start = '<START>';
const String pad = '<PAD>';
const String unk = '<UNKNOWN>';

class SentimentClassifier extends Classifier {
  SentimentClassifier() : super(vocabFile, modelFile);

  Future<int> classify(String rawText) async {
    // tokenizeInputText returns List<List<double>>
    // of shape [1, 256].
    List<List<double>> input = tokenizeInputText(rawText);

    // output of shape [1,2].
    var output = List<double>.filled(2, 0).reshape([1, 2]);

    // The run method will run inference and
    // store the resulting values in output.
    interpreter.run(input, output);

    var result = 0;

    // If value of first element in output is greater than second,
    // then the sentence is negative
    if ((output[0][0] as double) > (output[0][1] as double)) {
      result = 0;
    } else {
      result = 1;
    }

    return result;
  }

  List<List<double>> tokenizeInputText(String text) {
    // Whitespace tokenization
    final toks = text.split(' ');

    // Create a list of length==_sentenceLen filled with the value <pad>
    var vec = List<double>.filled(sentenceLen, dict[pad]!.toDouble());

    var index = 0;
    if (dict.containsKey(start)) {
      vec[index++] = dict[start]!.toDouble();
    }

    // For each word in sentence find corresponding index in dict
    for (var tok in toks) {
      if (index > sentenceLen) {
        break;
      }
      vec[index++] =
          dict.containsKey(tok) ? dict[tok]!.toDouble() : dict[unk]!.toDouble();
    }

    // returning List<List<double>> as our interpreter input tensor expects the shape, [1,256]
    return [vec];
  }
}
