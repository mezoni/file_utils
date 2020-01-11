import 'dart:io';
import 'package:file_utils/file_utils.dart';
import 'package:test/test.dart';

void main() {
  _testExpand();
  _testName();
}

void _testExpand() {
  test('FilePath.expand()', () {
    String key;
    String value;
    if (Platform.isWindows) {
      key = r'$HOMEDRIVE$HOMEPATH';
      value = Platform.environment['HOMEDRIVE'];
      value += Platform.environment['HOMEPATH'];
    } else {
      key = r'$HOME';
      value = Platform.environment['HOME'];
    }

    value = FileUtils.fullpath(value);

    {
      final path = '$key';
      final result = FilePath.expand(path);
      final expected = value;
      expect(result, expected, reason: path);
    }
    {
      final path = '$key/1';
      final result = FilePath.expand(path);
      final expected = '$value/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '[]$key]1';
      final result = FilePath.expand(path);
      final expected = '[]$key]1';
      expect(result, expected, reason: path);
    }
    {
      final path = '[]$key]/1';
      final result = FilePath.expand(path);
      final expected = '[]$key]/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '[$key]$key/1';
      final result = FilePath.expand(path);
      final expected = '[$key]$value/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '\$/1';
      final result = FilePath.expand(path);
      final expected = '\$/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '\$/1';
      final result = FilePath.expand(path);
      final expected = '\$/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '\$lower_case/1';
      final result = FilePath.expand(path);
      final expected = '\$lower_case/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '\$1START_WITH_DIGIT/1';
      final result = FilePath.expand(path);
      final expected = '\$1START_WITH_DIGIT/1';
      expect(result, expected, reason: path);
    }
    {
      final path = '${key}lower/1';
      final home = FilePath.expand('~');
      final result = FilePath.expand(path);
      final expected = '${home}lower/1';
      expect(result, expected, reason: path);
    }
  });
}

void _testName() {
  test('FilePath.name()', () {
    {
      final path = '.';
      final result = FilePath.fullname(path);
      final current = FileUtils.getcwd();
      final expected = current;
      expect(result, expected);
    }
    {
      final path = '..';
      final result = FilePath.fullname(path);
      final current = FileUtils.getcwd();
      final expected = FileUtils.dirname(current);
      expect(result, expected);
    }
    {
      final path = './dir1';
      final result = FilePath.fullname(path);
      final current = FileUtils.getcwd();
      final expected = current + '/dir1';
      expect(result, expected);
    }
    {
      final path = './dir1/../../dir1';
      final result = FilePath.fullname(path);
      final current = FileUtils.getcwd();
      final expected = FileUtils.dirname(current) + '/dir1';
      expect(result, expected);
    }
  });
}
