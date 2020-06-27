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
  static final String COLUMN_TASK_ID = "id";
  static final String COLUMN_STATUS = "status";
  static final String COLUMN_URL = "url";
  static final String COLUMN_SAVED_DIR = "saved_dir";
  static final String COLUMN_FILE_NAME = "file_name";
  static final String COLUMN_TIME_CREATED = "time_created";
}

enum FilesState { loading, loaded, fail }
enum SearchState { typing, loading, done, empty, fail }
