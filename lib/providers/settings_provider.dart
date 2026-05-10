import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'search_history';
  static const String _darkModeKey = 'dark_mode';
  static const String _fahrenheitKey = 'fahrenheit';

  List<String> _favorites = [];
  List<String> _searchHistory = [];
  bool _isDarkMode = false;
  bool _isFahrenheit = false;

  SharedPreferences? _prefs;

  List<String> get favorites => _favorites;
  List<String> get searchHistory => _searchHistory;
  bool get isDarkMode => _isDarkMode;
  bool get isFahrenheit => _isFahrenheit;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    
    _favorites = _prefs?.getStringList(_favoritesKey) ?? [];
    _searchHistory = _prefs?.getStringList(_historyKey) ?? [];
    _isDarkMode = _prefs?.getBool(_darkModeKey) ?? false;
    _isFahrenheit = _prefs?.getBool(_fahrenheitKey) ?? false;
    
    notifyListeners();
  }

  // Favorites (E1)
  void toggleFavorite(String countryName) {
    if (_favorites.contains(countryName)) {
      _favorites.remove(countryName);
    } else {
      _favorites.add(countryName);
    }
    _prefs?.setStringList(_favoritesKey, _favorites);
    notifyListeners();
  }

  bool isFavorite(String countryName) {
    return _favorites.contains(countryName);
  }

  // Search History (E4)
  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // Remove if exists to put it at the top
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    
    // Keep only last 5
    if (_searchHistory.length > 5) {
      _searchHistory = _searchHistory.sublist(0, 5);
    }
    
    _prefs?.setStringList(_historyKey, _searchHistory);
    notifyListeners();
  }

  void clearHistory() {
    _searchHistory.clear();
    _prefs?.setStringList(_historyKey, _searchHistory);
    notifyListeners();
  }

  // Theme & Units (E5)
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  void toggleTemperatureUnit() {
    _isFahrenheit = !_isFahrenheit;
    _prefs?.setBool(_fahrenheitKey, _isFahrenheit);
    notifyListeners();
  }

  // Helper for temperature conversion
  double convertTemperature(double celsius) {
    if (_isFahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String get temperatureUnit => _isFahrenheit ? '°F' : '°C';
}
