import 'package:bddisk/Constant.dart';
import 'package:bddisk/models/SearchHistory.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  factory DbHelper() => _getInstance();

  static DbHelper get instance => _getInstance();
  static DbHelper _instance;

  DbHelper._internal();

  static DbHelper _getInstance() {
    if (_instance == null) {
      _instance = new DbHelper._internal();
    }
    return _instance;
  }

  Database _db;

  Future<Database> get getDb async {
    if (_db == null) _db = await _initDb();
    return _db;
  }

  _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, Constant.dbName);
    return await openDatabase(
      path,
      version: Constant.dbVersion,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) => db.execute('create table ${Constant.searchHistoryTable}'
      '('
      '"id" integer primary key autoincrement,'
      '"keyword" text, '
      '"time" integer'
      ')');

  void close() async {
    if (_db != null) await _db.close();
  }

  Future<SearchHistory> insert(SearchHistory searchHistory) async {
    var __db = await getDb;
    try {
      searchHistory.id = await __db.insert(Constant.searchHistoryTable, searchHistory.toMap());
    } catch (e) {
      print(e);
    }
    return searchHistory;
  }

  Future<SearchHistory> query(int id) async {
    var __db = await getDb;
    List<Map> maps = await __db.query(Constant.searchHistoryTable, where: 'id = ?', whereArgs: [id]);
    if (maps.length > 0) return SearchHistory.fromMap(maps.first);
    return null;
  }

  Future<List<SearchHistory>> search(String key) async {
    var __db = await getDb;
    List<Map> maps = await __db.query(Constant.searchHistoryTable, where: 'keyword like %?%', whereArgs: [key]);
    var list = List<SearchHistory>();
    maps.forEach((element) {
      list.add(SearchHistory.fromMap(element));
    });
    return list;
  }

  Future<List<SearchHistory>> queryAll() async {
    var __db = await getDb;
    List<Map> maps = await __db.query(Constant.searchHistoryTable);
    var list = List<SearchHistory>();
    maps.forEach((element) {
      list.add(SearchHistory.fromMap(element));
    });
    print("queryAll");
    print(maps);
    return list;
  }

  Future<int> deleteAll() async {
    var __db = await getDb;

    return await __db.delete(Constant.searchHistoryTable);
  }

  Future<int> deleteById(int id) async {
    var __db = await getDb;

    return await __db.delete(Constant.searchHistoryTable, where: 'id = ?', whereArgs: [id]);
  }
}
