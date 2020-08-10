import 'package:bddisk/helpers/Prefs.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // 该 token 来自互联网，仅供学习交流。
  // 因为学习的需要所以找到一个带上传权限的 token，上传目录：/apps/ES文件浏览器/
  static final String baiduClientId = 'NqOMXF6XGhGRIGemsQ9nG0Na';

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
    _bdOAuth2Token = BdOAuth2Token.fromJSON(json);
    return _bdOAuth2Token;
  }

  Future<bool> requestStoragePermissions() async {
    bool isGranted = await Permission.storage.request().isGranted;
    if (isGranted) {
      return true;
    } else {
      if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
  }
}
