import 'package:bddisk/helpers/Prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Constant.dart';
import 'models/BdOAuth2Token.dart';

class AppConfig {
  factory AppConfig() => _getInstance();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static AppConfig get instance => _getInstance();
  static AppConfig _instance;

  AppConfig._internal();

  static AppConfig _getInstance() {
    if (_instance == null) {
      _instance = new AppConfig._internal();
    }
    return _instance;
  }

  static final String baiduClientId = 'iap3UEKzq5KeVg3KDj9bTfRt';

  static final String baiduOAuth2Url =
      'https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=$baiduClientId&redirect_uri=oob&scope=basic,netdisk&display=mobile&state=xxx';

  BdOAuth2Token _bdOAuth2Token;

  void setToken(BdOAuth2Token t) {
    _bdOAuth2Token = t;
  }

  Future<BdOAuth2Token> get token async {
    if (_bdOAuth2Token != null) return _bdOAuth2Token;

    var prefs = await _prefs;
    if (!prefs.containsKey(Constant.keyBdOAuth2Token)) return null;

    var json = prefs.getJson(Constant.keyBdOAuth2Token);
    _bdOAuth2Token = BdOAuth2Token.fromJson(json);
    return _bdOAuth2Token;
  }
}
