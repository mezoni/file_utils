import 'dart:io';
import 'package:file_utils/file_utils.dart';
import 'package:path/path.dart' as pathos;
import 'package:test/test.dart';

void main() {
  _testAbsolute();
  _testCrossing();
  _testOnlyDirectory();
  _testRelative();
  _testTilde();
}

void _testAbsolute() {
  test('Absolute', () {
    {
      var path = FileUtils.getcwd();
      var mask = 'lib/src/*.dart';
      mask = path + '/' + mask;
      var files = FileList(Directory(path), mask);
      final expected = ['file_list.dart', 'file_path.dart', 'file_utils.dart'];
      final result1 = <String>[];
      for (final file in files) {
        result1.add(FileUtils.basename(file));
      }

      result1.sort((a, b) => a.compareTo(b));
      expect(result1, expected, reason: mask);
      path = pathos.rootPrefix(path);
      files = FileList(Directory(path), mask);
      final result2 = <String>[];
      for (final file in files) {
        result2.add(FileUtils.basename(file));
      }

      result2.sort((a, b) => a.compareTo(b));
      expect(result2, expected, reason: mask);
    }
  });
}

void _testCrossing() {
  test('Crossing', () {
    {
      final path = FileUtils.getcwd();
      final mask = '**/example*.dart';
      final files = FileList(Directory(path), mask);
      final expected = [
        'example.dart',
        'example_file_list.dart',
        'example_file_path.dart',
      ];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      final path = FileUtils.getcwd();
      final mask = 'lib/**/file_list.dart';
      final files = FileList(Directory(path), mask);
      final expected = ['file_list.dart'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      final path = FileUtils.getcwd();
      final mask = 'lib/**/';
      final files = FileList(Directory(path), mask);
      final expected = ['src'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      final path = FileUtils.getcwd();
      var mask = 'lib/**/file_list.dart';
      mask = path + '/' + mask;
      final files = FileList(Directory(path), mask);
      final expected = ['file_list.dart'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      final path = FileUtils.getcwd();
      var mask = 'lib/**/';
      mask = path + '/' + mask;
      final files = FileList(Directory(path), mask);
      final expected = ['src'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
  });
}

void _testOnlyDirectory() {
  test('OnlyDirectory', () {
    {
      final path = FileUtils.getcwd();
      final mask = '*/';
      final files = FileList(Directory(path), mask);
      final expected = ['example', 'lib', 'test'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      final mask = '**/';
      path = path + '/' + 'lib';
      final files = FileList(Directory(path), mask);
      final expected = ['src'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      final path = FileUtils.getcwd();
      final mask = path + '/*/';
      final files = FileList(Directory(path), mask);
      final expected = ['example', 'lib', 'test'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
    {
      var path = FileUtils.getcwd();
      path = path + '/' + 'lib';
      final mask = path + '/**/';
      final files = FileList(Directory(path), mask);
      final expected = ['src'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
  });
}

void _testRelative() {
  test('Relative', () {
    {
      final path = FileUtils.getcwd();
      final mask = 'lib/src/*.dart';
      final files = FileList(Directory(path), mask);
      final expected = ['file_list.dart', 'file_path.dart', 'file_utils.dart'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }

    {
      final path = FileUtils.getcwd();
      final mask = 'lib/*/';
      final files = FileList(Directory(path), mask);
      final expected = ['src'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }

    {
      final path = FileUtils.getcwd();
      final mask = 'lib/src/';
      final files = FileList(Directory(path), mask);
      final expected = ['src'];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected, reason: mask);
    }
  });
}

void _testTilde() {
  test('Tilde', () {
    {
      final mask = '~/*/';
      final home = FilePath.expand('~');
      final files = FileList(Directory(home), mask);
      final result = files.isNotEmpty;
      expect(result, true, reason: mask);
    }
  });
}
