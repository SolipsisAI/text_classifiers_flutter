import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'util.dart';

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
    if (modelFile.startsWith('assets://')) {
      interpreter = await Interpreter.fromAsset('models/$modelFile');
    } else {
      final file = File(modelFile);
      interpreter = Interpreter.fromFile(file);
    }
    debugPrint('Interpreter $modelFile loaded successfully');
  }

  void _loadDictionary() async {
    final vocabFilename = vocabFile.startsWith('assets://')
        ? 'assets/models/$vocabFile'
        : vocabFile;

    final vocab = await rootBundle.loadString(vocabFilename);

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
