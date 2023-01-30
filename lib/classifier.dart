import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ml_linalg/linalg.dart';

Vector softmax(List<double> output) {
  // Compute the softmax
  final vector1 = Vector.fromList(output);
  final expVec = vector1.exp();
  final sum = expVec.toList().reduce((a, b) => a + b);
  final result = expVec.scalarDiv(sum);
  final max = result.max();
  debugPrint('softmax: $max');
  return result;
}

int argmax(Vector input) {
  double maxVal = input.max();
  var index = 0;
  for (var i = 0; i < input.length; i++) {
    if (input[i] == maxVal) {
      index = i;
      break;
    }
  }
  return index;
}

class Classifier {
  late String vocabFile;
  late String modelFile;

  late Map<String, int> dict;
  late Interpreter interpreter;

  Classifier(this.vocabFile, this.modelFile) {
    _loadModel();
    _loadDictionary();
  }

  void _loadModel() async {
    // Creating the interpreter using Interpreter.fromAsset
    interpreter = await Interpreter.fromAsset('models/$modelFile');
    debugPrint('Interpreter $modelFile loaded successfully');
  }

  void _loadDictionary() async {
    final vocab = await rootBundle.loadString('assets/models/$vocabFile');
    var tempDict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      tempDict[entry[0]] = int.parse(entry[1]);
    }
    dict = tempDict;
    debugPrint('$vocabFile loaded successfully as Dictionary');
  }
}
