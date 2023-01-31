import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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
