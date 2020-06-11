class DiskFile {
  /// 文件绝对路径
  String path;

  /// 文件名
  String serverFilename;

  /// 是否目录，0 文件、1 目录
  int isDir;

  /// 文件创建时间
  int serverCTime;

  /// 文件大小，单位B
  int size;

  /// 文件类型，1 视频、2 音频、3 图片、4 文档、5 应用、6 其他、7 种子
  int category;

  DiskFile({this.path, this.serverFilename, this.serverCTime, this.category = 6, this.isDir = 1, this.size = 0});
}
