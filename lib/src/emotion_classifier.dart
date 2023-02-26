import 'package:tflite_flutter/tflite_flutter.dart';
import 'classifier.dart';
import 'util.dart';

const defaultVocabFile = 'emotion_classification.vocab.txt';
const defaultModelFile = 'emotion_classification.tflite';

const int _sentenceLen = 256;
const String start = '[CLS]';
const String pad = '[PAD]';
const String unk = '[UNK]';
const String sep = '[SEP]';

class EmotionClassifier extends Classifier {
  String vocab;
  String model;
  int interpreterAddress;

  final List<String> labels = [
    "sadness",
    "joy",
    "love",
    "anger",
    "fear",
    "surprise"
  ];

  EmotionClassifier(
      {this.model = defaultModelFile,
      this.vocab = defaultVocabFile,
      this.interpreterAddress = -1})
      : super(vocab, model, address: interpreterAddress);

  Future<String> classify(String rawText) async {
    // tokenizeInputText returns List<List<double>>
    // of shape [1, 256].
    List<List<int>> input = tokenizeInputText(rawText);

    // output of shape [1,6]
    // example: [[-1.434808373451233, -0.602688729763031, 4.8783135414123535, -1.720102071762085, -0.9065110087394714, -1.056220293045044]]
    var output = List<double>.filled(6, 0).reshape([1, 6]);

    // The run method will run inference and
    // store the resulting values in output.
    interpreter.run(input, output);

    // Compute the softmax
    final result = softmax(output[0]);
    final labelIndex = argmax(result);
    return labels[labelIndex];
  }

  List<List<int>> tokenizeInputText(String text) {
    // Whitespace tokenization
    final toks = text.split(' ');

    // Create a list of length==_sentenceLen filled with the value <pad>
    var vec = List<int>.filled(_sentenceLen, dict[pad]!);

    var index = 0;
    if (dict.containsKey(start)) {
      vec[index++] = dict[start]!;
    }

    // For each word in sentence find corresponding index in dict
    for (var tok in toks) {
      if (index > _sentenceLen) {
        break;
      }
      var encoded = wordPiece(sanitizeString(tok, false));
      for (var word in encoded) {
        var sanitizedWord = sanitizeString(word, false);
        vec[index++] =
            dict.containsKey(sanitizedWord) ? dict[sanitizedWord]! : dict[unk]!;
      }
    }

    // EOS
    vec[index++] = dict[sep]!;

    // returning List<List<double>> as our interpreter input tensor expects the shape, [1,256]
    return [vec];
  }

  List wordPiece(String input) {
    // Based on https://huggingface.co/course/chapter6/6?fw=pt#tokenization-algorithm
    var word = input.toLowerCase();
    var tokens = [];

    while (word.isNotEmpty) {
      var i = word.length;
      while (i > 0 && !dict.containsKey(word.substring(0, i))) {
        i -= 1;
      }
      if (i == 0) return ["[UNK]"];
      tokens.add(word.substring(0, i));
      word = word.substring(i, word.length);
      if (word.isNotEmpty) word = '##$word';
    }

    return tokens;
  }
}
