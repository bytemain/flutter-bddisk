import 'dart:io';

import 'DiskFile.dart';

class SystemFile extends DiskFile {
  SystemFile.fromSystem(FileSystemEntity file) {
    FileStat fileStat = file.statSync();
    int timestamp = fileStat.modified.toLocal().millisecondsSinceEpoch;
    print("timestamp $timestamp");
    int isDir = FileSystemEntity.isDirectorySync(file.path) == true ? 1 : 0;
    super.path = file.path;
    super.serverFilename = file.path.substring(file.parent.path.length + 1);
    super.serverCTime = timestamp;
    super.size = fileStat.size;
    super.isDir = isDir;
  }
}
