import 'package:bddisk/helpers/DbHelper.dart';
import 'package:bddisk/models/SearchHistory.dart';

import '../Constant.dart';

class SearchHistoryDbHelper {
  static Future<SearchHistory> insert(SearchHistory searchHistory) async {
    var __db = await DbHelper.instance.db;
    try {
      searchHistory.id = await __db.insert(SearchHistoryContract.TABLE_NAME, searchHistory.toMap());
    } catch (e) {
      print(e);
    }
    return searchHistory;
  }

  static Future<SearchHistory> query(int id) async {
    var __db = await DbHelper.instance.db;
    List<Map> maps = await __db
        .query(SearchHistoryContract.TABLE_NAME, where: '${SearchHistoryContract.COLUMN_ID} = ?', whereArgs: [id]);
    if (maps.length > 0) return SearchHistory.fromMap(maps.first);
    return null;
  }

  static Future<List<SearchHistory>> search(String key) async {
    var __db = await DbHelper.instance.db;
    List<Map> maps = await __db.query(SearchHistoryContract.TABLE_NAME,
        where: '${SearchHistoryContract.COLUMN_KEYWORD} like %?%', whereArgs: [key]);
    var list = List<SearchHistory>();
    maps.forEach((element) {
      list.add(SearchHistory.fromMap(element));
    });
    return list;
  }

  static Future<List<SearchHistory>> queryAll() async {
    var __db = await DbHelper.instance.db;
    List<Map> maps = await __db.query(SearchHistoryContract.TABLE_NAME);
    var list = List<SearchHistory>();
    maps.forEach((element) {
      list.add(SearchHistory.fromMap(element));
    });
    return list;
  }

  static Future<int> deleteAll() async {
    var __db = await DbHelper.instance.db;

    return await __db.delete(SearchHistoryContract.TABLE_NAME);
  }

  static Future<int> deleteById(int id) async {
    var __db = await DbHelper.instance.db;

    return await __db
        .delete(SearchHistoryContract.TABLE_NAME, where: '${SearchHistoryContract.COLUMN_ID} = ?', whereArgs: [id]);
  }
}
