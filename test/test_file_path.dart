import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:test/test.dart";

void main() {
  _testExpand();
  _testName();
}

void _testExpand() {
  test("FilePath.expand()", () {
    String key;
    String value;
    if (Platform.isWindows) {
      key = r"$HOMEDRIVE$HOMEPATH";
      value = Platform.environment["HOMEDRIVE"];
      value += Platform.environment["HOMEPATH"];
    } else {
      key = r"$HOME";
      value = Platform.environment["HOME"];
    }

    value = FileUtils.fullpath(value);

    {
      var path = "$key";
      var result = FilePath.expand(path);
      var expected = value;
      expect(result, expected, reason: path);
    }
    {
      var path = "$key/1";
      var result = FilePath.expand(path);
      var expected = "$value/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "[]$key]1";
      var result = FilePath.expand(path);
      var expected = "[]$key]1";
      expect(result, expected, reason: path);
    }
    {
      var path = "[]$key]/1";
      var result = FilePath.expand(path);
      var expected = "[]$key]/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "[$key]$key/1";
      var result = FilePath.expand(path);
      var expected = "[$key]$value/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "\$/1";
      var result = FilePath.expand(path);
      var expected = "\$/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "\$/1";
      var result = FilePath.expand(path);
      var expected = "\$/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "\$lower_case/1";
      var result = FilePath.expand(path);
      var expected = "\$lower_case/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "\$1START_WITH_DIGIT/1";
      var result = FilePath.expand(path);
      var expected = "\$1START_WITH_DIGIT/1";
      expect(result, expected, reason: path);
    }
    {
      var path = "${key}lower/1";
      var home = FilePath.expand("~");
      var result = FilePath.expand(path);
      var expected = "${home}lower/1";
      expect(result, expected, reason: path);
    }
  });
}

void _testName() {
  test("FilePath.name()", () {
    {
      var path = ".";
      var result = FilePath.fullname(path);
      var current = FileUtils.getcwd();
      var expected = current;
      expect(result, expected);
    }
    {
      var path = "..";
      var result = FilePath.fullname(path);
      var current = FileUtils.getcwd();
      var expected = FileUtils.dirname(current);
      expect(result, expected);
    }
    {
      var path = "./dir1";
      var result = FilePath.fullname(path);
      var current = FileUtils.getcwd();
      var expected = current + "/dir1";
      expect(result, expected);
    }
    {
      var path = "./dir1/../../dir1";
      var result = FilePath.fullname(path);
      var current = FileUtils.getcwd();
      var expected = FileUtils.dirname(current) + "/dir1";
      expect(result, expected);
    }
  });
}
