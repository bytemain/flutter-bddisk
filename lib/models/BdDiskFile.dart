import 'package:bddisk/models/DiskFile.dart';

class BdDiskFile extends DiskFile {
  int category;
  int fsId;
  int localCTime;
  int localMTime;
  int operId;
  String path;
  int privacy;
  int serverMTime;
  int share;
  int size;
  int unlist;

  BdDiskFile.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    fsId = json['fs_id'];
    isDir = json['isdir'];
    localCTime = json['local_ctime'];
    localMTime = json['local_mtime'];
    operId = json['oper_id'];
    path = json['path'];
    privacy = json['privacy'];
    serverCTime = json['server_ctime'];
    serverFilename = json['server_filename'];
    serverMTime = json['server_mtime'];
    share = json['share'];
    size = json['size'];
    unlist = json['unlist'];
  }
}
