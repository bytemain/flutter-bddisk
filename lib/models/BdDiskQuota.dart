class BdDiskQuota {
  int errNo;
  int used;
  int total;
  int requestId;

  double get percentage => ((used ?? 0) / (total ?? 1));

  BdDiskQuota.fromJSON(Map<String, dynamic> json) {
    errNo = json["errno"];
    used = json["used"];
    total = json["total"];
    requestId = json["request_id"];
  }
  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errno'] = this.errNo;
    data['total'] = this.total;
    data['request_id'] = this.requestId;
    data['used'] = this.used;
    return data;
  }
}
