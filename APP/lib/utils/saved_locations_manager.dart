import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedLocationsManager {
  static const String _key = 'saved_locations';

  Future<List<Map<String, dynamic>>> getSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveLocation(String cityName, double temperature) async {
    final prefs = await SharedPreferences.getInstance();
    final locations = await getSavedLocations();
    
    // Remove if already exists
    locations.removeWhere((location) => location['name'] == cityName);
    
    // Add to beginning
    locations.insert(0, {
      'name': cityName,
      'temperature': temperature.round(),
      'savedAt': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 10
    if (locations.length > 10) {
      locations.removeRange(10, locations.length);
    }
    
    await prefs.setString(_key, json.encode(locations));
  }

  Future<void> removeLocation(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final locations = await getSavedLocations();
    
    locations.removeWhere((location) => location['name'] == cityName);
    
    await prefs.setString(_key, json.encode(locations));
  }

  Future<bool> isLocationSaved(String cityName) async {
    final locations = await getSavedLocations();
    return locations.any((location) => location['name'] == cityName);
  }

  Future<void> updateLocationTemperature(String cityName, double temperature) async {
    final prefs = await SharedPreferences.getInstance();
    final locations = await getSavedLocations();
    
    final index = locations.indexWhere((location) => location['name'] == cityName);
    if (index != -1) {
      locations[index]['temperature'] = temperature.round();
      locations[index]['updatedAt'] = DateTime.now().toIso8601String();
      await prefs.setString(_key, json.encode(locations));
    }
  }

  Future<void> clearAllLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}