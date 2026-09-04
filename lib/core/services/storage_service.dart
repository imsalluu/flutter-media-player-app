import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _recentKey = 'recent';

  Future<void> toggleFavorite(String mediaId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    if (favorites.contains(mediaId)) {
      favorites.remove(mediaId);
    } else {
      favorites.add(mediaId);
    }
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addToRecent(String mediaId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList(_recentKey) ?? [];
    
    recent.remove(mediaId); // Remove if already exists to move to top
    recent.insert(0, mediaId);
    
    if (recent.length > 50) {
      recent = recent.sublist(0, 50);
    }
    await prefs.setStringList(_recentKey, recent);
  }

  Future<List<String>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? [];
  }

  static const String _playbackPositionsKey = 'playback_positions_';

  Future<void> savePlaybackPosition(String mediaId, int positionMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_playbackPositionsKey$mediaId', positionMs);
  }

  Future<int> getPlaybackPosition(String mediaId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_playbackPositionsKey$mediaId') ?? 0;
  }

  Future<void> clearPlaybackPosition(String mediaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_playbackPositionsKey$mediaId');
  }

  static const String _themeKey = 'theme_mode';

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }
}

