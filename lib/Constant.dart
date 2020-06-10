class Constant {
  static String dbName = "test";
  static String searchHistoryTable = "test";
  static int dbVersion = 1;
  static final String keyUserInfo = 'json_user_info';
  static final String keyDiskQuota = 'json_disk_quota';
  static final String keyBdOAuth2Token = 'json_baidu_oauth2_token';
}

enum FilesState { loading, loaded, fail }
enum SearchState { typing, loading, done, empty, fail }
