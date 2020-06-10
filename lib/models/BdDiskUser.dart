class BdDiskUser {
  String avatarUrl;
  String baiduName;
  String errMsg;
  int errNo;
  String netDiskName;
  String requestId;
  int uk;
  int vipType;

  BdDiskUser.fromJSON(Map<String, dynamic> json) {
    avatarUrl = json["avatar_url"];
    baiduName = json["baidu_name"];
    errMsg = json["errmsg"];
    errNo = json["errno"];
    netDiskName = json["netdisk_name"];
    requestId = json["request_id"];
    uk = json["uk"];
    vipType = json["vip_type"];
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar_url'] = this.avatarUrl;
    data['baidu_name'] = this.baiduName;
    data['errmsg'] = this.errMsg;
    data['errno'] = this.errNo;
    data['netdisk_name'] = this.netDiskName;
    data['request_id'] = this.requestId;
    data['uk'] = this.uk;
    data['vip_type'] = this.vipType;
    return data;
  }
}
