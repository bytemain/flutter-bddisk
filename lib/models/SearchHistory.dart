class SearchHistory {
  int id;
  String keyword;
  int time;

  SearchHistory(this.keyword, {this.id, this.time});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "keyword": this.keyword,
      "time": this.time ?? DateTime.now().millisecondsSinceEpoch,
    };
    if (this.id != null) map['id'] = this.id;
    return map;
  }

  static SearchHistory fromMap(Map<String, dynamic> map) =>
      SearchHistory(map["keyword"], id: map["id"], time: map["time"]);
}
