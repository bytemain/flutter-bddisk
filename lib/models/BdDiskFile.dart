class BdDiskFile {
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

  /// 文件的md5值，只有是文件类型时
  String md5;

  String dLink;

  /// 包含三个尺寸的缩略图URL
  Thumbs thumbs;

  BdDiskFile.fromJSON(Map<String, dynamic> json) {
    category = json['category'];
    fsId = json['fs_id'];
    isDir = json['isdir'];
    localCTime = json['local_ctime'];
    localMTime = json['local_mtime'];
    operId = json['oper_id'];
    path = json['path'];
    privacy = json['privacy'];
    serverCTime = json['server_ctime'];
    serverFilename = json['server_filename'] ?? json["filename"];
    serverMTime = json['server_mtime'];
    share = json['share'];
    size = json['size'];
    unlist = json['unlist'];
    dLink = json["dlink"];
    thumbs = json['thumbs'] != null ? new Thumbs.fromJson(json['thumbs']) : null;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();
    data['server_mtime'] = this.serverMTime;
    data['unlist'] = this.unlist;
    data['fs_id'] = this.fsId;
    data['oper_id'] = this.operId;
    data['server_ctime'] = this.serverCTime;
    data['local_mtime'] = this.localMTime;
    if (this.thumbs != null) {
      data['thumbs'] = this.thumbs.toJson();
    }
    data['share'] = this.share;
    data['md5'] = this.md5;
    data['local_ctime'] = this.localCTime;
    return data;
  }
}

class Thumbs {
  String icon;
  String url3;
  String url2;
  String url1;

  Thumbs({this.icon, this.url3, this.url2, this.url1});

  Thumbs.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    url3 = json['url3'];
    url2 = json['url2'];
    url1 = json['url1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['url3'] = this.url3;
    data['url2'] = this.url2;
    data['url1'] = this.url1;
    return data;
  }
}
