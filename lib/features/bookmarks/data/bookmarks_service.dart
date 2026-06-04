import 'package:shared_preferences/shared_preferences.dart';

class BookmarksService {
  static const _key = 'bookmarked_content_ids';

  Future<Set<String>> getBookmarkedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<bool> isBookmarked(String id) async {
    final ids = await getBookmarkedIds();
    return ids.contains(id);
  }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getBookmarkedIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_key, ids.toList());
  }
}
