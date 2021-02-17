import 'dart:io';
import 'package:file_utils/file_utils.dart';

void main() {
  final pubCache = getPubCachePath();
  // Find "CHANGELOG" in "pub cache"
  final mask = '**/CHANGELOG*';
  final directory = Directory(pubCache);
  final files = FileList(directory, mask, caseSensitive: false);
  if (files.isNotEmpty) {
    final list = files.toList();
    final length = list.length;
    print("Found $length 'CHANGELOG' files");
    for (var file in files) {
      print(file);
    }
  }
}

String getPubCachePath() {
  var result = Platform.environment['PUB_CACHE'];
  if (result != null) {
    return result;
  }

  if (Platform.isWindows) {
    result = FilePath.expand(r'$APPDATA/Pub/Cache');
  } else {
    result = FilePath.expand('~/.pub-cache');
  }

  return result;
}
