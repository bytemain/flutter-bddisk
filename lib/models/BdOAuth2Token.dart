class BdOAuth2Token {
  /// 登录鉴权
  String accessToken;

  /// 鉴权过期时间，单位秒
  int expiresIn;

  /// 鉴权创建时间,单位秒
  int createTime;

  bool get isExpired => (createTime + expiresIn) <= DateTime.now().millisecondsSinceEpoch ~/ 1000;

  BdOAuth2Token(this.accessToken, {this.expiresIn, this.createTime}) {
    this.createTime ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  BdOAuth2Token.fromJson(Map<String, dynamic> json) {
    this.accessToken = json['access_token'];
    this.expiresIn = json['expires_in'];
    this.createTime = json['create_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['access_token'] = this.accessToken;
    json['expires_in'] = this.expiresIn;
    json['create_time'] = this.createTime;
    return json;
  }
}
