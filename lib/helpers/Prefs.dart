import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesExtension on SharedPreferences {
  Future<bool> setJson(String key, Map<String, dynamic> json) {
    assert(json != null);
    assert(key != null);

    var value = jsonEncode(json);
    return this.setString(key, value);
  }

  Map<String, dynamic> getJson(String key) {
    assert(key != null);

    var value = this.getString(key);
    var json = jsonDecode(value);
    return json;
  }
}