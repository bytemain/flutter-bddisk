import 'package:bddisk/Constant.dart';

class SearchHistory {
  int id;
  String keyword;
  int time;

  SearchHistory(this.keyword, {this.id, this.time});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      SearchHistoryContract.COLUMN_KEYWORD: this.keyword,
      SearchHistoryContract.COLUMN_TIME: this.time ?? DateTime.now().millisecondsSinceEpoch,
    };
    if (this.id != null) map[SearchHistoryContract.COLUMN_ID] = this.id;
    return map;
  }

  static SearchHistory fromMap(Map<String, dynamic> map) => SearchHistory(map[SearchHistoryContract.COLUMN_KEYWORD],
      id: map[SearchHistoryContract.COLUMN_ID], time: map[SearchHistoryContract.COLUMN_TIME]);
}
