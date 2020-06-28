import 'package:flutter/cupertino.dart';

class Constant {
  static final String keyUserInfo = 'json_user_info';
  static final String keyDiskQuota = 'json_disk_quota';
  static final String keyBdOAuth2Token = 'json_baidu_oauth2_token';
}

class DbConstant {
  static final String dbName = "bddisk.db";
  static final int dbVersion = 1;
}

class SearchHistoryContract {
  static final String TABLE_NAME = "search_history";
  static final String COLUMN_ID = "id";
  static final String COLUMN_KEYWORD = "keyword";
  static final String COLUMN_TIME = "time";
}

class DownloadContract {
  static final String TABLE_NAME = "download";
  static final String COLUMN_ID = "id";
  static final String COLUMN_TASK_ID = "task_id";
  static final String COLUMN_REMARKS = "remarks";
}

enum FilesState { loading, loaded, fail }
enum SearchState { typing, loading, done, empty, fail }

class Choice {
  const Choice(
    this.key, {
    this.title,
    this.icon,
  });

  final String key;
  final String title;
  final IconData icon;
}
