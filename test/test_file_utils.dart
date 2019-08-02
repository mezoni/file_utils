import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:test/test.dart";

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
  FileUtils.rm(["file*", "dir*"], recursive: true);
}

void _testBasename() {
  test("FileUtils.basename()", () {
    if (Platform.isWindows) {
      _testBasenameOnWindows();
    } else {
      _testBasenameOnPosix();
    }

    var tests = <List<String>>[];
    tests.add(["stdio.h", ".h", "stdio"]);
    tests.add(["stdio.h", ".cpp", "stdio.h"]);
    tests.add(["dir/file.name.ext", "ame.ext", "file.n"]);
    for (var test in tests) {
      var source = test[0];
      var suffix = test[1];
      var expected = test[2];
      var result = FileUtils.basename(source, suffix: suffix);
      expect(result, expected);
    }
  });
}

void _testBasenameOnPosix() {
  var tests = <List<String>>[];
  tests.add(["/", ""]);
  tests.add(["//", ""]);
  tests.add(["/1", "1"]);
  tests.add(["/1/", "1"]);
  tests.add(["/1//", "1"]);
  tests.add(["/1//2", "2"]);
  tests.add(["/1//2/", "2"]);
  tests.add(["/1//2//", "2"]);
  tests.add([".", "."]);
  tests.add(["", ""]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.basename(source);
    expect(result, expected);
  }
}

void _testBasenameOnWindows() {
  var tests = <List<String>>[];
  tests.add([r"c:\", ""]);
  tests.add([r"c:\\", ""]);
  tests.add([r"\", ""]);
  // TODO:
  //tests.add([r"\\", ""]);
  tests.add([r"c:\1", "1"]);
  tests.add([r"c:\1\", "1"]);
  tests.add([r"c:\1\2", "2"]);
  tests.add([r"c:\1\2\", "2"]);
  tests.add([".", "."]);
  tests.add(["", ""]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.basename(source);
    expect(result, expected);
  }
}

void _testChdir() {
  test("FileUtils.chdir()", () {
    {
      var source = ".";
      var expected = "file_utils";
      FileUtils.chdir(source);
      var path = FileUtils.getcwd();
      var result = FileUtils.basename(path);
      expect(result, expected);
    }
    {
      FileUtils.chdir("test");
      var source = "..";
      var expected = "file_utils";
      FileUtils.chdir(source);
      var path = FileUtils.getcwd();
      var result = FileUtils.basename(path);
      expect(result, expected);
    }
    {
      var restore = FileUtils.getcwd();
      var source = "test";
      var expected = "test";
      FileUtils.chdir(source);
      var path = FileUtils.getcwd();
      var result = FileUtils.basename(path);
      expect(result, expected);
      FileUtils.chdir(restore);
    }
    {
      var restore = FileUtils.getcwd();
      var result = FileUtils.chdir("~");
      expect(result, true);
      FileUtils.chdir(restore);
    }
    {
      var restore = FileUtils.getcwd();
      var result = FileUtils.chdir("~/");
      expect(result, true);
      FileUtils.chdir(restore);
    }
    {
      var restore = FileUtils.getcwd();
      FileUtils.chdir("~");
      var home = FileUtils.getcwd();
      var mask = home + "/" + "*/";
      var dirs = FileUtils.glob(mask);
      for (var dir in dirs) {
        var name = FileUtils.basename(dir);
        var path = "~/$name";
        var result = FileUtils.chdir(path);
        expect(result, true);
        FileUtils.chdir("..");
      }

      FileUtils.chdir(restore);
    }
  });
}

void _testDirEmpty() {
  test("FileUtils.dirEmpty()", () {
    _clean();
    {
      // Empty directory
      FileUtils.mkdir(["dir"]);
      var result = FileUtils.dirempty("dir");
      expect(result, true);
    }
    {
      FileUtils.mkdir(["dir/dir"]);
      var result = FileUtils.dirempty("dir");
      expect(result, false);
    }

    {
      FileUtils.rm(["dir"], recursive: true);
      var result = FileUtils.dirempty("dir");
      expect(result, false);
    }

    _clean();
  });
}

void _testDirname() {
  test("FileUtils.dirname()", () {
    //
    if (Platform.isWindows) {
      _testDirnameWindows();
    } else {
      _testDirnamePosix();
    }
  });
}

void _testDirnamePosix() {
  var tests = <List<String>>[];
  tests.add(["/", "/"]);
  tests.add(["", "."]);
  tests.add(["1", "."]);
  tests.add(["1/", "."]);
  tests.add(["/1", "/"]);
  tests.add(["1/2", "1"]);
  tests.add(["1///2", "1"]);
  tests.add(["/1//2/", "/1"]);
  tests.add(["/1//2//", "/1"]);
  tests.add([".", "."]);
  tests.add(["", "."]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.dirname(source);
    expect(result, expected);
  }
}

void _testDirnameWindows() {
  var tests = <List<String>>[];
  tests.add([r"C:\", r"C:/"]);
  tests.add([r"", "."]);
  tests.add([r"1", "."]);
  tests.add([r"1\", "."]);
  tests.add([r"\1", r"/"]);
  tests.add([r"1\2", "1"]);
  tests.add([r"1\\2", "1"]);
  tests.add([r"\1\2\", r"/1"]);
  tests.add([r"\1\\2\\", r"/1"]);
  tests.add([r"C:\1", r"C:/"]);
  tests.add([r"C:\1\2\", r"C:/1"]);
  tests.add([r"C:\1\2\\", r"C:/1"]);

  tests.add([".", "."]);
  tests.add(["", "."]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.dirname(source);
    expect(result, expected);
  }
}

void _testExclude() {
  test("FileUtils.exclude()", () {
    _clean();
    {
      var restore = FileUtils.getcwd();
      FileUtils.chdir("test");
      var mask = "*_utils.dart";
      var files = FileUtils.glob("*.dart");
      var result = FileUtils.exclude(files, mask);
      result = result.map((e) => FileUtils.basename(e)).toList();
      result.sort((a, b) => a.compareTo(b));
      var expected = ["test_file_list.dart", "test_file_path.dart"];
      expect(result, expected);
      FileUtils.chdir(restore);
    }

    _clean();
  });
}

void _testFullPath() {
  test("FileUtils.fullpath()", () {
    _clean();
    {
      var result = FileUtils.fullpath(".");
      var expected = FileUtils.getcwd();
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("./");
      var expected = FileUtils.getcwd();
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("./test");
      var expected = FileUtils.getcwd() + "/test";
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath(".test");
      var expected = ".test";
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("..");
      var save = FileUtils.getcwd();
      FileUtils.chdir("..");
      var expected = FileUtils.getcwd();
      FileUtils.chdir(save);
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("../");
      var save = FileUtils.getcwd();
      FileUtils.chdir("..");
      var expected = FileUtils.getcwd();
      FileUtils.chdir(save);
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("../test");
      var save = FileUtils.getcwd();
      FileUtils.chdir("..");
      var expected = FileUtils.getcwd() + "/test";
      FileUtils.chdir(save);
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("..test");
      var expected = "..test";
      expect(result, expected);
    }
    {
      var result = FileUtils.fullpath("~");
      var expected = FilePath.expand("~");
      expect(result, expected);
    }

    _clean();
  });
}

void _testGetcwd() {
  test("FileUtils.getcwd()", () {
    {
      var result = FileUtils.getcwd();
      result = FileUtils.basename(result);
      expect(result, "file_utils");
    }
  });
}

void _testGlob() {
  test("FileUtils.glob()", () {
    {
      var restore = FileUtils.getcwd();
      FileUtils.chdir("test");
      var files = FileUtils.glob("*.dart");
      var expected = [
        "test_file_list.dart",
        "test_file_path.dart",
        "test_file_utils.dart"
      ];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected);
      FileUtils.chdir(restore);
    }
    {
      var path = FileUtils.getcwd();
      path = path + "/test";
      var mask = path + "/*.dart";
      var files = FileUtils.glob(mask);
      var expected = [
        "test_file_list.dart",
        "test_file_path.dart",
        "test_file_utils.dart"
      ];
      var result = <String>[];
      for (var file in files) {
        result.add(FileUtils.basename(file));
      }

      result.sort((a, b) => a.compareTo(b));
      expect(result, expected);
    }
    {
      var mask = "~/*/";
      var files = FileUtils.glob(mask);
      var result = files.isNotEmpty;
      expect(result, true);
    }
  });
}

void _testInclude() {
  test("FileUtils.include()", () {
    _clean();
    {
      var mask = "*spec.yaml";
      var files = FileUtils.glob("*.yaml");
      var result = FileUtils.include(files, mask);
      result = result.map((e) => FileUtils.basename(e)).toList();
      result.sort((a, b) => a.compareTo(b));
      var expected = ["pubspec.yaml"];
      expect(result, expected);
    }

    _clean();
  });
}

void _testMakeDir() {
  test("FileUtils.mkdir()", () {
    _clean();
    {
      var result = FileUtils.mkdir(["dir1"]);
      expect(result, true);
    }

    _clean();
  });
}

void _testMove() {
  test("FileUtils.move()", () {
    _clean();
    {
      FileUtils.mkdir(["dir1", "dir2"]);
      FileUtils.touch(["dir1/file1.txt", "dir1/file2.txt"]);
      var result = FileUtils.move(["dir1/*.txt"], "dir2");
      expect(result, true);
      result = FileUtils.dirempty("dir1");
      expect(result, true);
      result = FileUtils.dirempty("dir2");
      expect(result, false);
    }

    _clean();
  });
}

void _testRemove() {
  test("FileUtils.rm()", () {
    _clean();
    var subject = "rm";
    {
      FileUtils.touch(["file"]);
      var result = FileUtils.rm(["file"]);
      expect(result, true, reason: "$subject, file");
    }
    {
      FileUtils.mkdir(["dir"]);
      var result = FileUtils.rm(["dir"]);
      expect(result, false, reason: "$subject, directory");
    }
    {
      var result = FileUtils.rm(["dir"], directory: true);
      expect(result, true, reason: "$subject, empty directory");
    }
    {
      FileUtils.mkdir(["dir"]);
      FileUtils.touch(["dir/file"]);
      var result = FileUtils.rm(["dir"], directory: true);
      expect(result, false, reason: "$subject, non empty directory");
      result = FileUtils.rm(["dir"], recursive: true);
      expect(result, true, reason: "$subject, non empty directory");
    }
    {
      var result = FileUtils.rm(["non-exist"]);
      expect(result, false, reason: "$subject, non exists file");
      result = FileUtils.rm(["non-exist"], directory: true);
      expect(result, false, reason: "$subject, non exists file");
      result = FileUtils.rm(["non-exist"], recursive: true);
      expect(result, false, reason: "$subject, non exists file");
      result = FileUtils.rm(["non-exist"], force: true);
      expect(result, true, reason: "$subject, non exists file");
    }

    _clean();
  });
}

void _testRemoveDir() {
  test("FileUtils.rmdir()", () {
    _clean();
    var subject = "rmdir";
    {
      FileUtils.touch(["file"]);
      var result = FileUtils.rmdir(["file"]);
      expect(result, false, reason: "$subject, file");
      FileUtils.rm(["file"]);
    }
    {
      FileUtils.mkdir(["dir"]);
      var result = FileUtils.rmdir(["dir"]);
      expect(result, true, reason: "$subject, empty directory");
    }
    {
      FileUtils.mkdir(["dir"]);
      FileUtils.touch(["dir/file"]);
      var result = FileUtils.rmdir(["dir"]);
      expect(result, false, reason: "$subject, directory with file");
      FileUtils.rm(["dir/file"]);
    }
    {
      FileUtils.mkdir(["dir/dir"]);
      var result = FileUtils.rmdir(["dir"], parents: true);
      expect(result, true, reason: "$subject, directory with only directory");
      FileUtils.rm(["dir"], recursive: true);
    }
    {
      var result = FileUtils.rmdir(["non-exists"]);
      expect(result, false, reason: "$subject, non exists");
    }

    _clean();
  });
}

void _testRename() {
  test("FileUtils.rename()", () {
    {
      {
        _clean();
        FileUtils.touch(["file1"]);
        var result = FileUtils.rename("file1", "file2");
        expect(result, true);
        result = FileUtils.testfile("file1", "file");
        expect(result, false);
        result = FileUtils.testfile("file2", "file");
        expect(result, true);
      }
    }
    {
      _clean();
      FileUtils.touch(["file1"]);
      FileUtils.mkdir(["dir"]);
      var result = FileUtils.rename("file1", "dir/file");
      expect(result, true);
      result = FileUtils.testfile("file", "file");
      expect(result, false);
      result = FileUtils.testfile("dir/file", "file");
      expect(result, true);
    }
    {
      _clean();

      FileUtils.mkdir(["dir1"]);
      FileUtils.mkdir(["dir2"]);
      FileUtils.touch(["dir1/file1"]);
      var result = FileUtils.rename("dir1", "dir2/dir3");
      expect(result, true);
      result = FileUtils.testfile("dir2/dir3", "directory");
      expect(result, true);
      result = FileUtils.testfile("dir2/dir3/file1", "file");
      expect(result, true);
      result = FileUtils.testfile("dir1", "directory");
      expect(result, false);
      FileUtils.rm(["dir2"], recursive: true);
    }

    _clean();
    // TODO: test move link
  });
}

void _testSymlink() {
  test("FileUtils.symlink()", () {
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
    var target = "file";
    var link = "file.link";
    FileUtils.touch([target]);
    var result = FileUtils.symlink(target, link);
    expect(result, true);
    result = FileUtils.testfile(link, "link");
    expect(result, true);
    result = FileUtils.testfile(link, "file");
    expect(result, true);
  }
  {
    _clean();
    var target = "dir";
    var link = "dir.link";
    FileUtils.mkdir([target]);
    var result = FileUtils.symlink(target, link);
    expect(result, true);
    result = FileUtils.testfile(link, "link");
    expect(result, true);
    result = FileUtils.testfile(link, "directory");
    expect(result, true);
  }

  _clean();
}

void _testSymlinkOnWindows() {
  {
    _clean();
    var target = "dir";
    var link = "dir.link";
    FileUtils.mkdir([target]);
    var result = FileUtils.symlink(target, link);
    expect(result, true);
    result = FileUtils.testfile(link, "link");
    expect(result, true);
    result = FileUtils.testfile(link, "directory");
    expect(result, true);
  }

  _clean();
}

void _testTestfile() {
  test("FileUtils.testfile()", () {
    _clean();
    {
      var path = FileUtils.getcwd();
      path = path + "/test/test_file_utils.dart";
      var source = path;
      var result = FileUtils.testfile(source, "file");
      expect(result, true);
      result = FileUtils.testfile(source, "exists");
      expect(result, true);
    }
    {
      var path = FileUtils.getcwd();
      path = path + "/test/test_file_utils.dart";
      var source = FileUtils.dirname(path);
      var result = FileUtils.testfile(source, "directory");
      expect(result, true);
      result = FileUtils.testfile(source, "exists");
      expect(result, true);
    }
    {
      var source = "dir";
      var link = "dir.link";
      FileUtils.mkdir([source]);
      FileUtils.symlink(source, link);
      var result = FileUtils.testfile(link, "link");
      expect(result, true);
    }

    _clean();
  });
}

void _testTouch() {
  test("FileUtils.touch()", () {
    _clean();
    {
      var dir = "dir";
      var file = "file";
      var path = "$dir/$file";
      var result = FileUtils.touch([path]);
      expect(result, false);
      result = FileUtils.testfile(path, file);
      expect(result, false);
    }
    {
      var dir = "dir";
      var file = "file";
      var path = "$dir/$file";
      FileUtils.mkdir([dir]);
      var result = FileUtils.touch([path]);
      expect(result, true);
      result = FileUtils.testfile(path, file);
      expect(result, true);
    }
    {
      var dir = "dir";
      var file = "file";
      var path = "$dir/$file";
      FileUtils.rm([dir], recursive: true);
      var result = FileUtils.touch([path], create: false);
      expect(result, true);
      result = FileUtils.testfile(path, file);
      expect(result, false);
    }
    {
      var dir = "dir";
      var file = "file";
      var path = "$dir/$file";
      FileUtils.mkdir([dir]);
      var result = FileUtils.touch([path], create: false);
      expect(result, true);
      result = FileUtils.testfile(path, file);
      expect(result, false);
    }

    _clean();
    {
      var file = "file";
      FileUtils.touch([file]);
      var stat1 = FileStat.statSync(file);
      // https://code.google.com/p/dart/issues/detail?id=18442
      _wait(1000);
      FileUtils.touch([file]);
      var stat2 = FileStat.statSync(file);
      var result = stat2.modified.compareTo(stat1.modified) > 0;
      expect(result, true);
    }

    _clean();
  });
}

void _testUptodate() {
  test("FileUtils.uptodate()", () {
    _clean();
    {
      var result = FileUtils.uptodate("file1");
      expect(result, false);
    }
    {
      FileUtils.touch(["file1"]);
      var result = FileUtils.uptodate("file1");
      expect(result, true);
    }
    {
      var result = FileUtils.uptodate("file1", ["file2"]);
      expect(result, false);
    }
    {
      _wait(1000);
      FileUtils.touch(["file2"]);
      var result = FileUtils.uptodate("file1", ["file2"]);
      expect(result, false);
    }

    _clean();
  });
}

void _wait(int milliseconds) {
  var sw = Stopwatch();
  sw.start();
  while (sw.elapsedMilliseconds < milliseconds) {
    //
  }
  sw.stop();
}
