import 'package:shared_preferences/shared_preferences.dart';

/// Local save: highest unlocked level + stars per level (1-200).
class ProgressService {
  ProgressService(this._prefs);

  final SharedPreferences _prefs;

  static Future<ProgressService> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressService(prefs);
  }

  int get unlockedLevel => _prefs.getInt('unlocked') ?? 1;

  int starsFor(int level) => _prefs.getInt('stars_$level') ?? 0;

  int get totalStars {
    var total = 0;
    for (var i = 1; i <= 200; i++) {
      total += starsFor(i);
    }
    return total;
  }

  Future<void> saveResult(int level, int stars) async {
    final old = starsFor(level);
    if (stars > old) await _prefs.setInt('stars_$level', stars);
    if (stars > 0 && level >= unlockedLevel && level < 200) {
      await _prefs.setInt('unlocked', level + 1);
    }
  }
}
