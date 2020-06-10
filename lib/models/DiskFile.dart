class DiskFile {
  // 文件绝对路径
  String path;
  // 文件名
  String serverFilename;
  int isDir;
  int serverCTime;
  int size;
  int category;

  DiskFile({this.path, this.serverFilename, this.serverCTime, this.category = 6, this.isDir = 1, this.size = 0});
}
