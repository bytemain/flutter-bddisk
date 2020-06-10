import 'package:bddisk/helpers/Prefs.dart';
import 'package:bddisk/models/BdDiskQuota.dart';
import 'package:bddisk/models/BdDiskUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant.dart';
import 'BdDiskApiClient.dart';

class UserRepository {
  final BdDiskApiClient apiClient;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  UserRepository({BdDiskApiClient apiClient}) : this.apiClient = apiClient ?? BdDiskApiClient();

  /// 获取用户信息，网络异常时，返回缓存信息
  Future<BdDiskUser> getUserInfo() async {
    BdDiskUser user;
    var prefs = await _prefs;
    try {
      user = await apiClient.getUserInfo();
    } catch (e) {
      if (prefs.containsKey(Constant.keyUserInfo)) return BdDiskUser.fromJSON(prefs.getJson(Constant.keyUserInfo));
      return null;
    }

    prefs.setJson(Constant.keyUserInfo, user.toJSON());
    return user;
  }

  /// 获取网盘信息，网络异常时，返回缓存信息
  Future<BdDiskQuota> getDiskQuota() async {
    var prefs = await _prefs;
    BdDiskQuota quota;

    try {
      quota = await apiClient.getDiskQuota();
    } catch (e) {
      if (prefs.containsKey(Constant.keyDiskQuota)) return BdDiskQuota.fromJSON(prefs.getJson(Constant.keyDiskQuota));
      return null;
    }

    prefs.setJson(Constant.keyDiskQuota, quota.toJSON());
    return quota;
  }

  /// 获取网盘信息，网络异常时，返回缓存信息
  Future<Map<String, dynamic>> logout() async {
    var prefs = await _prefs;

    Map response = await apiClient.logout();
    prefs.remove(Constant.keyBdOAuth2Token);
    prefs.remove(Constant.keyDiskQuota);
    prefs.remove(Constant.keyUserInfo);
    return response;
  }
}
