import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _sessionKey = 'cinerate.session.userId';

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionKey);
  }

  Future<void> setCurrentUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, userId);
  }

  Future<void> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
