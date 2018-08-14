import "package:file_utils/file_utils.dart";

void main() {
  // Expand path
  var path = FilePath.expand("~");
  print(path);

  // Full path name
  path = FilePath.fullname("~/video/../music");
  print(path);
}
