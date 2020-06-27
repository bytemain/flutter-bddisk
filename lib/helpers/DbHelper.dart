import 'package:bddisk/Constant.dart';
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

  Future<Database> get db async {
    if (_db == null) _db = await _initDb();
    return _db;
  }

  _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, DbConstant.dbName);
    return await openDatabase(
      path,
      version: DbConstant.dbVersion,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) {
    db.execute('create table ${SearchHistoryContract.TABLE_NAME}'
        '('
        '"${SearchHistoryContract.COLUMN_ID}" integer primary key autoincrement,'
        '"${SearchHistoryContract.COLUMN_KEYWORD}" text, '
        '"${SearchHistoryContract.COLUMN_TIME}" integer'
        ')');
//    db.execute('create table ${DownloadContract.TABLE_NAME}'
//        '('
//        '"id" integer primary key autoincrement,'
//        ')');
  }

  void close() async {
    if (_db != null) await _db.close();
  }
}
