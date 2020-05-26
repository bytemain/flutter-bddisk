import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../DiskFile.dart';
import '../SystemFile.dart';
import 'FileStore.dart';

class SystemFileStore implements FileStore {
  @override
  Future<List<DiskFile>> list(String dir, {String order = 'name', int start = 0, int limit = 1000}) async {
    print("list files, dir: $dir");
    Directory directory = Directory(dir);
    var diskFiles = List<DiskFile>();
    if (dir == null) return diskFiles;

    int count = 0;
    var _diskFilesComplete = Completer();
    var listOfFiles = directory.list();
    listOfFiles.listen((file) {
      print("file： ${file.path}");
      var fileName = p.basename(file.path);
      print("fileName $fileName");
      // AppConfig.instance.showAllFiles
      if (file.path == null || fileName.substring(0, 1) == "." || count++ < start) return;
      if (count > start + limit) {
        if (!_diskFilesComplete.isCompleted) {
          _diskFilesComplete.complete('');
        }
      }
      print("added");
      diskFiles.add(SystemFile.fromSystem(file));
    }, onDone: () {
      if (!_diskFilesComplete.isCompleted) {
        _diskFilesComplete.complete('');
      }
    }, onError: (e) => _diskFilesComplete.completeError(e));
    await _diskFilesComplete.future;
    FileStore.sortFiles(diskFiles, order);
    return diskFiles;
  }

  @override
  Future<List<DiskFile>> search(String key, {String dir = "/", int recursion = 1, int page = 1, int num = 1000}) async {
    Directory directory = Directory(dir);
    var diskFiles = List<DiskFile>();
    int count = 0;
    int start = (page - 1) * num;
    var listOfFiles = directory.list(recursive: recursion == 1 ? true : false);
    var _diskFilesComplete = Completer();
    listOfFiles.listen((file) {
      print("file： ${file.path}");
      var fileName = p.basename(file.path);
      print("fileName $fileName");
      // AppConfig.instance.showAllFiles
      if (file.path == null ||
          fileName.substring(0, 1) == "." ||
          !fileName.toLowerCase().contains(key.toLowerCase()) ||
          count++ < start) return;
      if (count > start + num) {
        if (!_diskFilesComplete.isCompleted) {
          _diskFilesComplete.complete('');
        }
      }
      print("added");
      diskFiles.add(SystemFile.fromSystem(file));
    }, onDone: () {
      if (!_diskFilesComplete.isCompleted) {
        _diskFilesComplete.complete('');
      }
    }, onError: (e) => _diskFilesComplete.completeError(e));

    await _diskFilesComplete.future;
    return diskFiles;
  }
}
