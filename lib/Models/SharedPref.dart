import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  static Future<void> setStringValue(String key, String value) async {
    final prefs = await _prefs;
    prefs.setString(key, value);
  }
  static Future<String?> getStringValue(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }
  static Future<void> setIntValue(String key, int value) async {
    final prefs = await _prefs;
    prefs.setInt(key, value);
  }

  static Future<int?> getIntValue(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }
  static Future<bool> isLoggedIn() async {
    String? token = await SharedPref.getStringValue("accessToken");
    if(token != null){
      return true;
    }else{
      return false;
    }
    // return token != null && token.isNotEmpty;
  }


}