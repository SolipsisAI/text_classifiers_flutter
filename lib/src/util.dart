import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:path_provider/path_provider.dart';

const baseS3Url = 'https://solipsis-data.s3.us-east-2.amazonaws.com/models';

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

String sanitizeString(String text, bool stripPunctuation) {
  String sanitized = text.toLowerCase();
  if (stripPunctuation) {
    return sanitized.replaceAll(RegExp("[^A-Za-z0-9']"), '');
  }
  return sanitized;
}

Future<String> getModelsDir() async {
  String appdirpath = (await getApplicationSupportDirectory()).path;
  return '$appdirpath/models';
}

void downloadModel(String modelName) async {
  final modelsDir = await getModelsDir();
  Directory(modelsDir).create(recursive: true);

  final modelUrl = '$baseS3Url/$modelName.tflite';
  final modelPath = '$modelsDir/$modelName.tflite';
  downloadFile(modelUrl, modelPath, 'bytes', modelsDir);

  final vocabUrl = '$baseS3Url/$modelName.vocab.txt';
  final vocabPath = '$modelsDir/$modelName.vocab.txt';
  downloadFile(vocabUrl, vocabPath, 'string', modelsDir);
}

void downloadFile(
    String? url, String? filename, String? type, String? downloaddir) async {
  String filepath = '$downloaddir/$filename';

  debugPrint('[DOWNLOAD] $url -> $filepath');

  if (File(filepath).existsSync()) {
    debugPrint('[SKIP] Exists');
    return;
  }

  final client = http.Client();
  final response = await client.get(Uri.parse(url!));

  File file = File(filepath);

  if (type == 'bytes') {
    await file.writeAsBytes(response.bodyBytes);
  } else {
    await file.writeAsString(response.body);
  }

  debugPrint("[SUCCESS] Downloaded $filepath");
}
