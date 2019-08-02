import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:path/path.dart" as pathos;
import "package:test/test.dart";

void main() {
  _testAbsolute();
  _testCrossing();
  _testOnlyDirectory();
  _testRelative();
  _testTilde();
}

void _testAbsolute() {
  test("Absolute", () {
    {
      var path = FileUtils.getcwd();
      var mask = "lib/src/*.dart";
      mask = path + "/" + mask;
      var files = FileList(Directory(path), mask);
      var expected = ["file_list.dart", "file_path.dart", "file_utils.dart"];
      var result1 = <String>[];
      for (var file in files) {
        result1.add(FileUtils.basename(file));
      }

      result1.sort((a, b) => a.compareTo(b));
      expect(result1, expected, reason: mask);
      path = pathos.rootPrefix(path);
      files = FileList(Directory(path), mask);
      var result2 = <String>[];
      for (var file in files) {
        result2.add(FileUtils.basename(file));
      }

      result2.sort((a, b) => a.compareTo(b));
      expect(result2, expected, reason: mask);
    }
  });
}

void _testCrossing() {
  test("Crossing", () {
    {
      var path = FileUtils.getcwd();
      var mask = "**/example*.dart";
      var files = FileList(Directory(path), mask);
      var expected = [
        'example.dart',
        'example_file_list.dart',
        'example_file_path.dart',
      ];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      var mask = "lib/**/file_list.dart";
      var files = FileList(Directory(path), mask);
      var expected = ["file_list.dart"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      var mask = "lib/**/";
      var files = FileList(Directory(path), mask);
      var expected = ["src"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      var mask = "lib/**/file_list.dart";
      mask = path + "/" + mask;
      var files = FileList(Directory(path), mask);
      var expected = ["file_list.dart"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      var mask = "lib/**/";
      mask = path + "/" + mask;
      var files = FileList(Directory(path), mask);
      var expected = ["src"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
  });
}

void _testOnlyDirectory() {
  test("OnlyDirectory", () {
    {
      var path = FileUtils.getcwd();
      var mask = "*/";
      var files = FileList(Directory(path), mask);
      var expected = ["example", "lib", "test"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      var mask = "**/";
      path = path + "/" + "lib";
      var files = FileList(Directory(path), mask);
      var expected = ["src"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      var mask = path + "/*/";
      var files = FileList(Directory(path), mask);
      var expected = ["example", "lib", "test"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      path = path + "/" + "lib";
      var mask = path + "/**/";
      var files = FileList(Directory(path), mask);
      var expected = ["src"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
  });
}

void _testRelative() {
  test("Relative", () {
    {
      var path = FileUtils.getcwd();
      var mask = "lib/src/*.dart";
      var files = FileList(Directory(path), mask);
      var expected = ["file_list.dart", "file_path.dart", "file_utils.dart"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }

    {
      var path = FileUtils.getcwd();
      var mask = "lib/*/";
      var files = FileList(Directory(path), mask);
      var expected = ["src"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }

    {
      var path = FileUtils.getcwd();
      var mask = "lib/src/";
      var files = FileList(Directory(path), mask);
      var expected = ["src"];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
  });
}

void _testTilde() {
  test("Tilde", () {
    {
      var mask = "~/*/";
      var home = FilePath.expand("~");
      if (home != null) {
        var files = FileList(Directory(home), mask);
        var result = files.isNotEmpty;
        expect(result, true, reason: mask);
      }
    }
  });
}
