import 'package:bddisk/models/DiskFile.dart';

class BdDiskFile extends DiskFile {
  int fsId;

  /// 文件在客户端创建时间
  int localCTime;

  /// 文件在客户端修改时间
  int localMTime;
  int operId;
  int privacy;

  /// 文件在服务器修改时间,
  int serverMTime;
  int share;
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
