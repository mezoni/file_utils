import 'dart:io';
import 'package:file_utils/file_utils.dart';
import 'package:test/test.dart';

void main() {
  _testBasename();
  _testChdir();
  _testDirEmpty();
  _testDirname();
  _testExclude();
  _testFullPath();
  _testGetcwd();
  _testGlob();
  _testInclude();
  _testMakeDir();
  _testMove();
  _testRemove();
  _testRemoveDir();
  _testRename();
  _testSymlink();
  _testTestfile();
  _testTouch();
  _testUptodate();
}

void _clean() {
  FileUtils.rm(['file*', 'dir*'], recursive: true);
}

void _testBasename() {
  test('FileUtils.basename()', () {
    if (Platform.isWindows) {
      _testBasenameOnWindows();
    } else {
      _testBasenameOnPosix();
    }

    final tests = <List<String>>[];
    tests.add(['stdio.h', '.h', 'stdio']);
    tests.add(['stdio.h', '.cpp', 'stdio.h']);
    tests.add(['dir/file.name.ext', 'ame.ext', 'file.n']);
    for (final test in tests) {
      final source = test[0];
      final suffix = test[1];
      final expected = test[2];
      final result = FileUtils.basename(source, suffix: suffix);
      expect(result, expected);
    }
  });
}

void _testBasenameOnPosix() {
  final tests = <List<String>>[];
  tests.add(['/', '']);
  tests.add(['//', '']);
  tests.add(['/1', '1']);
  tests.add(['/1/', '1']);
  tests.add(['/1//', '1']);
  tests.add(['/1//2', '2']);
  tests.add(['/1//2/', '2']);
  tests.add(['/1//2//', '2']);
  tests.add(['.', '.']);
  tests.add(['', '']);
  for (final test in tests) {
    final source = test[0];
    final expected = test[1];
    final result = FileUtils.basename(source);
    expect(result, expected);
  }
}

void _testBasenameOnWindows() {
  final tests = <List<String>>[];
  tests.add([r'c:\', '']);
  tests.add([r'c:\\', '']);
  tests.add([r'\', '']);
  // TODO:
  //tests.add([r'\\', '']);
  tests.add([r'c:\1', '1']);
  tests.add([r'c:\1\', '1']);
  tests.add([r'c:\1\2', '2']);
  tests.add([r'c:\1\2\', '2']);
  tests.add(['.', '.']);
  tests.add(['', '']);
  for (final test in tests) {
    final source = test[0];
    final expected = test[1];
    final result = FileUtils.basename(source);
    expect(result, expected);
  }
}

void _testChdir() {
  test('FileUtils.chdir()', () {
    {
      final source = '.';
      final expected = 'file_utils';
      FileUtils.chdir(source);
      final path = FileUtils.getcwd();
      final result = FileUtils.basename(path);
      expect(result, expected);
    }
    {
      FileUtils.chdir('test');
      final source = '..';
      final expected = 'file_utils';
      FileUtils.chdir(source);
      final path = FileUtils.getcwd();
      final result = FileUtils.basename(path);
      expect(result, expected);
    }
    {
      final restore = FileUtils.getcwd();
      final source = 'test';
      final expected = 'test';
      FileUtils.chdir(source);
      final path = FileUtils.getcwd();
      final result = FileUtils.basename(path);
      expect(result, expected);
      FileUtils.chdir(restore);
    }
    {
      final restore = FileUtils.getcwd();
      final result = FileUtils.chdir('~');
      expect(result, true);
      FileUtils.chdir(restore);
    }
    {
      final restore = FileUtils.getcwd();
      final result = FileUtils.chdir('~/');
      expect(result, true);
      FileUtils.chdir(restore);
    }
    {
      final restore = FileUtils.getcwd();
      FileUtils.chdir('~');
      final home = FileUtils.getcwd();
      final mask = home + '/' + '*/';
      final dirs = FileUtils.glob(mask);
      for (final dir in dirs) {
        final name = FileUtils.basename(dir);
        final path = '~/$name';
        final result = FileUtils.chdir(path);
        expect(result, true);
        FileUtils.chdir('..');
      }

      FileUtils.chdir(restore);
    }
  });
}

void _testDirEmpty() {
  test('FileUtils.dirEmpty()', () {
    _clean();
    {
      // Empty directory
      FileUtils.mkdir(['dir']);
      final result = FileUtils.dirempty('dir');
      expect(result, true);
    }
    {
      FileUtils.mkdir(['dir/dir']);
      final result = FileUtils.dirempty('dir');
      expect(result, false);
    }

    {
      FileUtils.rm(['dir'], recursive: true);
      final result = FileUtils.dirempty('dir');
      expect(result, false);
    }

    _clean();
  });
}

void _testDirname() {
  test('FileUtils.dirname()', () {
    //
    if (Platform.isWindows) {
      _testDirnameWindows();
    } else {
      _testDirnamePosix();
    }
  });
}

void _testDirnamePosix() {
  final tests = <List<String>>[];
  tests.add(['/', '/']);
  tests.add(['', '.']);
  tests.add(['1', '.']);
  tests.add(['1/', '.']);
  tests.add(['/1', '/']);
  tests.add(['1/2', '1']);
  tests.add(['1///2', '1']);
  tests.add(['/1//2/', '/1']);
  tests.add(['/1//2//', '/1']);
  tests.add(['.', '.']);
  tests.add(['', '.']);
  for (final test in tests) {
    final source = test[0];
    final expected = test[1];
    final result = FileUtils.dirname(source);
    expect(result, expected);
  }
}

void _testDirnameWindows() {
  final tests = <List<String>>[];
  tests.add([r'C:\', r'C:/']);
  tests.add([r'', '.']);
  tests.add([r'1', '.']);
  tests.add([r'1\', '.']);
  tests.add([r'\1', r'/']);
  tests.add([r'1\2', '1']);
  tests.add([r'1\\2', '1']);
  tests.add([r'\1\2\', r'/1']);
  tests.add([r'\1\\2\\', r'/1']);
  tests.add([r'C:\1', r'C:/']);
  tests.add([r'C:\1\2\', r'C:/1']);
  tests.add([r'C:\1\2\\', r'C:/1']);

  tests.add(['.', '.']);
  tests.add(['', '.']);
  for (final test in tests) {
    final source = test[0];
    final expected = test[1];
    final result = FileUtils.dirname(source);
    expect(result, expected);
  }
}

void _testExclude() {
  test('FileUtils.exclude()', () {
    _clean();
    {
      final restore = FileUtils.getcwd();
      FileUtils.chdir('test');
      final mask = '*_utils.dart';
      final files = FileUtils.glob('*.dart');
      var result = FileUtils.exclude(files, mask);
      result = result.map(FileUtils.basename).toList();
      result.sort((a, b) => a.compareTo(b));
      final expected = ['test_file_list.dart', 'test_file_path.dart'];
      expect(result, expected);
      FileUtils.chdir(restore);
    }

    _clean();
  });
}

void _testFullPath() {
  test('FileUtils.fullpath()', () {
    _clean();
    {
      final result = FileUtils.fullpath('.');
      final expected = FileUtils.getcwd();
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('./');
      final expected = FileUtils.getcwd();
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('./test');
      final expected = FileUtils.getcwd() + '/test';
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('.test');
      final expected = '.test';
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('..');
      final save = FileUtils.getcwd();
      FileUtils.chdir('..');
      final expected = FileUtils.getcwd();
      FileUtils.chdir(save);
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('../');
      final save = FileUtils.getcwd();
      FileUtils.chdir('..');
      final expected = FileUtils.getcwd();
      FileUtils.chdir(save);
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('../test');
      final save = FileUtils.getcwd();
      FileUtils.chdir('..');
      final expected = FileUtils.getcwd() + '/test';
      FileUtils.chdir(save);
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('..test');
      final expected = '..test';
      expect(result, expected);
    }
    {
      final result = FileUtils.fullpath('~');
      final expected = FilePath.expand('~');
      expect(result, expected);
    }

    _clean();
  });
}

void _testGetcwd() {
  test('FileUtils.getcwd()', () {
    {
      var result = FileUtils.getcwd();
      result = FileUtils.basename(result);
      expect(result, 'file_utils');
    }
  });
}

void _testGlob() {
  test('FileUtils.glob()', () {
    {
      final restore = FileUtils.getcwd();
      FileUtils.chdir('test');
      final files = FileUtils.glob('*.dart');
      final expected = [
        'test_file_list.dart',
        'test_file_path.dart',
        'test_file_utils.dart'
      ];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected);
      FileUtils.chdir(restore);
    }
    {
      var path = FileUtils.getcwd();
      path = path + '/test';
      final mask = path + '/*.dart';
      final files = FileUtils.glob(mask);
      final expected = [
        'test_file_list.dart',
        'test_file_path.dart',
        'test_file_utils.dart'
      ];
      final result = <String>[];
      for (final file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected);
    }
    {
      final mask = '~/*/';
      final files = FileUtils.glob(mask);
      final result = files.isNotEmpty;
      expect(result, true);
    }
  });
}

void _testInclude() {
  test('FileUtils.include()', () {
    _clean();
    {
      final mask = '*spec.yaml';
      final files = FileUtils.glob('*.yaml');
      var result = FileUtils.include(files, mask);
      result = result.map(FileUtils.basename).toList();
      result.sort((a, b) => a.compareTo(b));
      final expected = ['pubspec.yaml'];
      expect(result, expected);
    }

    _clean();
  });
}

void _testMakeDir() {
  test('FileUtils.mkdir()', () {
    _clean();
    {
      final result = FileUtils.mkdir(['dir1']);
      expect(result, true);
    }

    _clean();
  });
}

void _testMove() {
  test('FileUtils.move()', () {
    _clean();
    {
      FileUtils.mkdir(['dir1', 'dir2']);
      FileUtils.touch(['dir1/file1.txt', 'dir1/file2.txt']);
      var result = FileUtils.move(['dir1/*.txt'], 'dir2');
      expect(result, true);
      result = FileUtils.dirempty('dir1');
      expect(result, true);
      result = FileUtils.dirempty('dir2');
      expect(result, false);
    }

    _clean();
  });
}

void _testRemove() {
  test('FileUtils.rm()', () {
    _clean();
    final subject = 'rm';
    {
      FileUtils.touch(['file']);
      final result = FileUtils.rm(['file']);
      expect(result, true, reason: '$subject, file');
    }
    {
      FileUtils.mkdir(['dir']);
      final result = FileUtils.rm(['dir']);
      expect(result, false, reason: '$subject, directory');
    }
    {
      final result = FileUtils.rm(['dir'], directory: true);
      expect(result, true, reason: '$subject, empty directory');
    }
    {
      FileUtils.mkdir(['dir']);
      FileUtils.touch(['dir/file']);
      var result = FileUtils.rm(['dir'], directory: true);
      expect(result, false, reason: '$subject, non empty directory');
      result = FileUtils.rm(['dir'], recursive: true);
      expect(result, true, reason: '$subject, non empty directory');
    }
    {
      var result = FileUtils.rm(['non-exist']);
      expect(result, false, reason: '$subject, non exists file');
      result = FileUtils.rm(['non-exist'], directory: true);
      expect(result, false, reason: '$subject, non exists file');
      result = FileUtils.rm(['non-exist'], recursive: true);
      expect(result, false, reason: '$subject, non exists file');
      result = FileUtils.rm(['non-exist'], force: true);
      expect(result, true, reason: '$subject, non exists file');
    }

    _clean();
  });
}

void _testRemoveDir() {
  test('FileUtils.rmdir()', () {
    _clean();
    final subject = 'rmdir';
    {
      FileUtils.touch(['file']);
      final result = FileUtils.rmdir(['file']);
      expect(result, false, reason: '$subject, file');
      FileUtils.rm(['file']);
    }
    {
      FileUtils.mkdir(['dir']);
      final result = FileUtils.rmdir(['dir']);
      expect(result, true, reason: '$subject, empty directory');
    }
    {
      FileUtils.mkdir(['dir']);
      FileUtils.touch(['dir/file']);
      final result = FileUtils.rmdir(['dir']);
      expect(result, false, reason: '$subject, directory with file');
      FileUtils.rm(['dir/file']);
    }
    {
      FileUtils.mkdir(['dir/dir']);
      final result = FileUtils.rmdir(['dir'], parents: true);
      expect(result, true, reason: '$subject, directory with only directory');
      FileUtils.rm(['dir'], recursive: true);
    }
    {
      final result = FileUtils.rmdir(['non-exists']);
      expect(result, false, reason: '$subject, non exists');
    }

    _clean();
  });
}

void _testRename() {
  test('FileUtils.rename()', () {
    {
      {
        _clean();
        FileUtils.touch(['file1']);
        bool? result = FileUtils.rename('file1', 'file2');
        expect(result, true);
        result = FileUtils.testfile('file1', 'file');
        expect(result, false);
        result = FileUtils.testfile('file2', 'file');
        expect(result, true);
      }
    }
    {
      _clean();
      FileUtils.touch(['file1']);
      FileUtils.mkdir(['dir']);
      bool? result = FileUtils.rename('file1', 'dir/file');
      expect(result, true);
      result = FileUtils.testfile('file', 'file');
      expect(result, false);
      result = FileUtils.testfile('dir/file', 'file');
      expect(result, true);
    }
    {
      _clean();

      FileUtils.mkdir(['dir1']);
      FileUtils.mkdir(['dir2']);
      FileUtils.touch(['dir1/file1']);
      bool? result = FileUtils.rename('dir1', 'dir2/dir3');
      expect(result, true);
      result = FileUtils.testfile('dir2/dir3', 'directory');
      expect(result, true);
      result = FileUtils.testfile('dir2/dir3/file1', 'file');
      expect(result, true);
      result = FileUtils.testfile('dir1', 'directory');
      expect(result, false);
      FileUtils.rm(['dir2'], recursive: true);
    }

    _clean();
    // TODO: test move link
  });
}

void _testSymlink() {
  test('FileUtils.symlink()', () {
    if (Platform.isWindows) {
      _testSymlinkOnWindows();
    } else {
      _testSymlinkOnPosix();
    }
  });
}

void _testSymlinkOnPosix() {
  {
    _clean();
    final target = 'file';
    final link = 'file.link';
    FileUtils.touch([target]);
    bool? result = FileUtils.symlink(target, link);
    expect(result, true);
    result = FileUtils.testfile(link, 'link');
    expect(result, true);
    result = FileUtils.testfile(link, 'file');
    expect(result, true);
  }
  {
    _clean();
    final target = 'dir';
    final link = 'dir.link';
    FileUtils.mkdir([target]);
    bool? result = FileUtils.symlink(target, link);
    expect(result, true);
    result = FileUtils.testfile(link, 'link');
    expect(result, true);
    result = FileUtils.testfile(link, 'directory');
    expect(result, true);
  }

  _clean();
}

void _testSymlinkOnWindows() {
  {
    _clean();
    final target = 'dir';
    final link = 'dir.link';
    FileUtils.mkdir([target]);
    bool? result = FileUtils.symlink(target, link);
    expect(result, true);
    result = FileUtils.testfile(link, 'link');
    expect(result, true);
    result = FileUtils.testfile(link, 'directory');
    expect(result, true);
  }

  _clean();
}

void _testTestfile() {
  test('FileUtils.testfile()', () {
    _clean();
    {
      var path = FileUtils.getcwd();
      path = path + '/test/test_file_utils.dart';
      final source = path;
      var result = FileUtils.testfile(source, 'file');
      expect(result, true);
      result = FileUtils.testfile(source, 'exists');
      expect(result, true);
    }
    {
      var path = FileUtils.getcwd();
      path = path + '/test/test_file_utils.dart';
      final source = FileUtils.dirname(path);
      var result = FileUtils.testfile(source, 'directory');
      expect(result, true);
      result = FileUtils.testfile(source, 'exists');
      expect(result, true);
    }
    {
      final source = 'dir';
      final link = 'dir.link';
      FileUtils.mkdir([source]);
      FileUtils.symlink(source, link);
      final result = FileUtils.testfile(link, 'link');
      expect(result, true);
    }

    _clean();
  });
}

void _testTouch() {
  test('FileUtils.touch()', () {
    _clean();
    {
      final dir = 'dir';
      final file = 'file';
      final path = '$dir/$file';
      bool? result = FileUtils.touch([path]);
      expect(result, false);
      result = FileUtils.testfile(path, file);
      expect(result, false);
    }
    {
      final dir = 'dir';
      final file = 'file';
      final path = '$dir/$file';
      FileUtils.mkdir([dir]);
      bool? result = FileUtils.touch([path]);
      expect(result, true);
      result = FileUtils.testfile(path, file);
      expect(result, true);
    }
    {
      final dir = 'dir';
      final file = 'file';
      final path = '$dir/$file';
      FileUtils.rm([dir], recursive: true);
      bool? result = FileUtils.touch([path], create: false);
      expect(result, true);
      result = FileUtils.testfile(path, file);
      expect(result, false);
    }
    {
      final dir = 'dir';
      final file = 'file';
      final path = '$dir/$file';
      FileUtils.mkdir([dir]);
      bool? result = FileUtils.touch([path], create: false);
      expect(result, true);
      result = FileUtils.testfile(path, file);
      expect(result, false);
    }

    _clean();
    {
      final file = 'file';
      FileUtils.touch([file]);
      final stat1 = FileStat.statSync(file);
      // https://code.google.com/p/dart/issues/detail?id=18442
      _wait(1000);
      FileUtils.touch([file]);
      final stat2 = FileStat.statSync(file);
      final result = stat2.modified.compareTo(stat1.modified) > 0;
      expect(result, true);
    }

    _clean();
  });
}

void _testUptodate() {
  test('FileUtils.uptodate()', () {
    _clean();
    {
      final result = FileUtils.uptodate('file1');
      expect(result, false);
    }
    {
      FileUtils.touch(['file1']);
      final result = FileUtils.uptodate('file1');
      expect(result, true);
    }
    {
      final result = FileUtils.uptodate('file1', ['file2']);
      expect(result, false);
    }
    {
      _wait(1000);
      FileUtils.touch(['file2']);
      final result = FileUtils.uptodate('file1', ['file2']);
      expect(result, false);
    }

    _clean();
  });
}

void _wait(int milliseconds) {
  final sw = Stopwatch();
  sw.start();
  while (sw.elapsedMilliseconds < milliseconds) {
    //
  }
  sw.stop();
}
