part of file_utils;

class FileList extends Object with ListMixin<String> {
  static final bool _isWindows = Platform.isWindows;

  final Directory directory;

  bool _caseSensitive;

  List<String> _files;

  void Function(String) _notify;

  String _pattern;

  /**
   * Creates file list.
   *
   * Parameters:
   *  [directory]
   *   Directory whic will be listed.
   *  [pattern]
   *   Glob pattern of this file list.
   *  [caseSensitive]
   *   True, if the pattern is case sensitive; otherwise false.
   *  [notify]
   *   Function that is called whenever an item is added.
   */
  FileList(this.directory, String pattern,
      {bool caseSensitive, void notify(String path)}) {
    if (directory == null) {
      throw new ArgumentError("directory: $directory");
    }

    if (pattern == null) {
      throw new ArgumentError("pattern: $pattern");
    }

    if (caseSensitive == null) {
      if (_isWindows) {
        caseSensitive = false;
      } else {
        caseSensitive = true;
      }
    }

    _caseSensitive = caseSensitive;
    _notify = notify;
    _pattern = FilePath.expand(pattern);
    _files = _getFiles();
  }

  /**
   * Returns the length.
   */
  int get length {
    return _files.length;
  }

  /**
   * Sets the length;
   */
  void set length(int length) {
    throw new UnsupportedError("length=");
  }

  String operator [](int index) {
    return _files[index];
  }

  void operator []=(int index, String value) {
    throw new UnsupportedError("[]=");
  }

  bool _exists(String path) {
    if (!new Directory(path).existsSync()) {
      if (!new File(path).existsSync()) {
        if (!new Link(path).existsSync()) {
          return false;
        }
      }
    }

    return true;
  }

  List<String> _getFiles() {
    var lister = new GlobLister(_pattern,
        caseSensitive: _caseSensitive,
        exists: _exists,
        isDirectory: _isDirectory,
        isWindows: _isWindows,
        list: _list);
    return lister.list(directory.path, notify: _notify);
  }

  bool _isDirectory(String path) {
    return new Directory(path).existsSync();
  }

  List<String> _list(String path, bool followLinks) {
    List<String> result;
    try {
      result = new Directory(path)
          .listSync(followLinks: followLinks)
          .map((e) => e.path)
          .toList();
    } catch (e) {
      result = new List<String>();
    }

    return result;
  }
}
