import "dart:io";
import "package:file_utils/file_utils.dart";

void main() {
  var pubCache = getPubCachePath();
  // Find "CHANGELOG" in "pub cache"
  if (pubCache != null) {
    var mask = "**/CHANGELOG*";
    var directory = Directory(pubCache);
    var files = FileList(directory, mask, caseSensitive: false);
    if (files.isNotEmpty) {
      var list = files.toList();
      var length = list.length;
      print("Found $length 'CHANGELOG' files");
      for (var file in files) {
        print(file);
      }
    }
  }
}

String getPubCachePath() {
  var result = Platform.environment["PUB_CACHE"];
  if (result != null) {
    return result;
  }

  if (Platform.isWindows) {
    result = FilePath.expand(r"$APPDATA/Pub/Cache");
  } else {
    result = FilePath.expand("~/.pub-cache");
  }

  return result;
}
