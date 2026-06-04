import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _key = 'recent_searches';
  static const _maxItems = 8;

  Future<List<String>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final updated = [q, ...list.where((e) => e != q)].take(_maxItems).toList();
    await prefs.setStringList(_key, updated);
  }

  Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    await prefs.setStringList(
      _key,
      list.where((e) => e != query).toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
