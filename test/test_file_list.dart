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
      var files = new FileList(new Directory(path), mask);
      var expected = ["file_list.dart", "file_path.dart", "file_utils.dart"];
      var result1 = <String>[];
      for (var file in files) {
        result1.add(FileUtils.basename(file));
      }

      result1.sort((a, b) => a.compareTo(b));
      expect(result1, expected, reason: mask);
      path = pathos.rootPrefix(path);
      files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
      var expected = [
        "example_file_list.dart",
        "example_file_path.dart",
        "example_file_utils.dart"
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
      var files = new FileList(new Directory(path), mask);
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
        var files = new FileList(new Directory(home), mask);
        var result = !files.isEmpty;
        expect(result, true, reason: mask);
      }
    }
  });
}
