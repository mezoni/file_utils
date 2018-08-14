import "dart:io";
import "package:file_utils/file_utils.dart";

void main() {
  // basename
  print("basename:");
  var path = FileUtils.getcwd();
  var name = FileUtils.basename(path);
  print("path: $path");
  print("name: $name");
  print("=============");

  // chdir
  print("chdir:");
  var save = FileUtils.getcwd();
  print("cwd: $save");

  FileUtils.chdir("..");
  path = FileUtils.getcwd();
  print("cwd: $path");

  FileUtils.chdir("~");
  path = FileUtils.getcwd();
  print("cwd: $path");

  FileUtils.chdir(save);
  path = FileUtils.getcwd();
  print("cwd: $path");
  print("=============");

  // dirempty
  print("dirempty:");

  var empty = FileUtils.dirempty(".");
  print("path: .");
  print("empty: $empty");

  FileUtils.mkdir(["temp"]);
  empty = FileUtils.dirempty("temp");
  print("path: temp");
  print("empty: $empty");
  FileUtils.rmdir(["temp"]);
  print("=============");

  // dirname
  print("dirname:");
  path = FileUtils.getcwd();
  name = FileUtils.dirname(path);
  print("path: $path");
  print("name: $name");
  print("=============");

  // exclude
  print("exclude:");
  var files = FileUtils.glob("*.yaml");
  files = FileUtils.exclude(files, "*spec.yaml");
  print("exclude: *spec.yaml");
  print("files: $files");
  print("=============");

  // fullpath
  print("fullpath:");
  path = FileUtils.fullpath("../file_utils");
  print("name: ../file_utils");
  print("path: $path");

  // getcwd
  print("getcwd:");
  path = FileUtils.getcwd();
  print("cwd: $path");
  print("=============");

  // glob
  print("glob:");  
  var dirs = FileUtils.glob("*/");
  dirs = dirs.map((e) => FileUtils.basename(e)).toList();
  print("glob: $dirs");  
  print("=============");

  // include
  print("include:");
  files = FileUtils.glob("*.yaml");
  files = FileUtils.include(files, "*spec.yaml");
  print("include: *spec.yaml");
  print("files: $files");
  print("=============");

  // mkdir
  print("mkdir:");
  FileUtils.mkdir(["temp"]);
  FileUtils.chdir("temp");
  path = FileUtils.getcwd();
  print("cwd: $path");
  FileUtils.chdir("..");
  FileUtils.rmdir(["temp"]);
  print("=============");

  // move
  print("move:");
  FileUtils.mkdir(["temp1", "temp2"]);
  FileUtils.touch(["temp1/file.txt"]);
  FileUtils.move(["temp1/*.txt"], "temp2");

  files = FileUtils.glob("temp1/*.txt");
  files = files.map((e) => FileUtils.basename(e)).toList();
  print("path: temp1");
  print("files: $files");

  files = FileUtils.glob("temp2/*.txt");
  files = files.map((e) => FileUtils.basename(e)).toList();
  print("path: temp2");
  print("files: $files");

  FileUtils.rm(["temp1", "temp2"], recursive: true);

  // rename
  print("rename:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.rename("temp1", "temp2");
  FileUtils.chdir("temp2");
  path = FileUtils.getcwd();
  print("cwd: $path");
  FileUtils.chdir("..");
  FileUtils.rmdir(["temp2"]);
  print("=============");

  // rm
  print("rm:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.chdir("temp1");
  FileUtils.touch(["temp1/file.txt"]);  
  FileUtils.rm(["temp1"], recursive: true);
  print("=============");

  // rmdir
  print("rmdir:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.chdir("temp1");
  FileUtils.chdir("..");
  FileUtils.rmdir(["temp1"]);
  print("=============");

  // symlink
  print("symlink:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.symlink("temp1", "temp2");
  FileUtils.chdir("temp2");
  path = FileUtils.getcwd();
  print("cwd: $path");
  FileUtils.chdir("..");
  FileUtils.rm(["temp1", "temp2"], recursive: true);
  print("=============");

  // testfile
  print("testfile:");
  FileUtils.mkdir(["temp1"]);
  var exists = FileUtils.testfile("temp1", "directory");
  print("path: temp1");
  print("exists: $exists");
  FileUtils.rmdir(["temp1"]);
  print("=============");

  // touch
  print("touch:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.touch(["temp1/file1.txt"]);
  exists = FileUtils.testfile("temp1/file1.txt", "file");
  print("path: temp1/file1.txt");
  print("exists: $exists");
  FileUtils.rm(["temp1"], recursive: true);
  print("=============");

  // uptodate
  print("uptodate:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.touch(["temp1/file1.txt"]);
  print("wait...");
  sleep(new Duration(milliseconds: 1000));
  FileUtils.touch(["temp1/file2.txt"]);
  var uptodate = FileUtils.uptodate("temp1/file1.txt", ["temp1/file2.txt"]);
  print("path: temp1/file1.txt");
  print("uptodate: $uptodate");
  FileUtils.rm(["temp1"], recursive: true);
  print("=============");
}
