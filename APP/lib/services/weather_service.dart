import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _baseUrl = 'https://weatherly-app-bp4c.onrender.com/api/v1';

  Future<Map<String, dynamic>> getWeatherData([String? city]) async {
    try {
      String endpoint;
      
      if (city != null && city.isNotEmpty) {
        endpoint = '$_baseUrl/weather/${Uri.encodeComponent(city)}';
      } else {
        // Get current location
        final position = await _getCurrentLocation();
        endpoint = '$_baseUrl/weather/coordinates?lat=${position.latitude}&lon=${position.longitude}';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _validateWeatherData(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockWeatherData(city ?? 'Unknown Location');
    }
  }

  Future<Map<String, dynamic>> getForecastData([String? city]) async {
    try {
      String endpoint;
      
      if (city != null && city.isNotEmpty) {
        endpoint = '$_baseUrl/forecast/${Uri.encodeComponent(city)}';
      } else {
        // Get current location
        final position = await _getCurrentLocation();
        endpoint = '$_baseUrl/forecast/coordinates?lat=${position.latitude}&lon=${position.longitude}';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _validateForecastData(data);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockForecastData(city ?? 'Unknown Location');
    }
  }

  Map<String, dynamic> _validateWeatherData(Map<String, dynamic> data) {
    // Ensure required fields exist
    if (data['data'] == null) {
      throw Exception('Invalid weather data structure');
    }

    final weatherData = data['data'] as Map<String, dynamic>;
    
    // Validate and provide defaults for required fields
    return {
      'success': data['success'] ?? true,
      'data': {
        'city': weatherData['city'] ?? 'Unknown City',
        'country': weatherData['country'] ?? 'Unknown',
        'coordinates': weatherData['coordinates'] ?? {'latitude': 0.0, 'longitude': 0.0},
        'temperature': {
          'current': (weatherData['temperature']?['current'] ?? 20).toDouble(),
          'feels_like': (weatherData['temperature']?['feels_like'] ?? 20).toDouble(),
          'min': (weatherData['temperature']?['min'] ?? 15).toDouble(),
          'max': (weatherData['temperature']?['max'] ?? 25).toDouble(),
        },
        'weather': {
          'main': weatherData['weather']?['main'] ?? 'Clear',
          'description': weatherData['weather']?['description'] ?? 'Clear sky',
          'icon': weatherData['weather']?['icon'] ?? '01d',
        },
        'details': {
          'humidity': weatherData['details']?['humidity'] ?? 50,
          'pressure': weatherData['details']?['pressure'] ?? 1013,
          'visibility': weatherData['details']?['visibility'] ?? 10,
          'wind_speed': (weatherData['details']?['wind_speed'] ?? 5).toDouble(),
          'wind_direction': weatherData['details']?['wind_direction'] ?? 0,
          'clouds': weatherData['details']?['clouds'] ?? 0,
        },
        'sun': {
          'sunrise': weatherData['sun']?['sunrise'] ?? '06:00',
          'sunset': weatherData['sun']?['sunset'] ?? '18:00',
        },
        'timezone': weatherData['timezone'] ?? 0,
        'updated_at': weatherData['updated_at'] ?? DateTime.now().toIso8601String(),
      },
      'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      'request_id': data['request_id'] ?? 'mock-id',
    };
  }

  Map<String, dynamic> _validateForecastData(Map<String, dynamic> data) {
    if (data['data'] == null) {
      throw Exception('Invalid forecast data structure');
    }

    final forecastData = data['data'] as Map<String, dynamic>;
    final forecast = forecastData['forecast'] as List? ?? [];
    
    return {
      'success': data['success'] ?? true,
      'data': {
        'city': forecastData['city'] ?? 'Unknown City',
        'country': forecastData['country'] ?? 'Unknown',
        'forecast': forecast.map((day) => {
          'date': day['date'] ?? DateTime.now().toIso8601String().split('T')[0],
          'day': day['day'] ?? 'Today',
          'temperature': {
            'min': (day['temperature']?['min'] ?? 15).toDouble(),
            'max': (day['temperature']?['max'] ?? 25).toDouble(),
            'average': (day['temperature']?['average'] ?? 20).toDouble(),
          },
          'weather': {
            'main': day['weather']?['main'] ?? 'Clear',
            'description': day['weather']?['description'] ?? 'Clear sky',
            'icon': day['weather']?['icon'] ?? '01d',
          },
          'details': {
            'humidity': day['details']?['humidity'] ?? 50,
            'wind_speed': (day['details']?['wind_speed'] ?? 5).toDouble(),
            'clouds': day['details']?['clouds'] ?? 0,
            'rain': (day['details']?['rain'] ?? 0).toDouble(),
            'snow': (day['details']?['snow'] ?? 0).toDouble(),
          },
        }).toList(),
      },
      'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      'request_id': data['request_id'] ?? 'mock-id',
    };
  }

  Map<String, dynamic> _getMockWeatherData(String city) {
    return {
      'success': true,
      'data': {
        'city': city,
        'country': 'Unknown',
        'coordinates': {'latitude': 0.0, 'longitude': 0.0},
        'temperature': {
          'current': 22.0,
          'feels_like': 24.0,
          'min': 18.0,
          'max': 26.0,
        },
        'weather': {
          'main': 'Clear',
          'description': 'Clear sky',
          'icon': '01d',
        },
        'details': {
          'humidity': 65,
          'pressure': 1013,
          'visibility': 10,
          'wind_speed': 3.5,
          'wind_direction': 120,
          'clouds': 15,
        },
        'sun': {
          'sunrise': '06:30',
          'sunset': '18:45',
        },
        'timezone': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      'timestamp': DateTime.now().toIso8601String(),
      'request_id': 'mock-weather-id',
    };
  }

  Map<String, dynamic> _getMockForecastData(String city) {
    final today = DateTime.now();
    final forecast = List.generate(5, (index) {
      final date = today.add(Duration(days: index));
      return {
        'date': date.toIso8601String().split('T')[0],
        'day': index == 0 ? 'Today' : _getDayName(date.weekday),
        'temperature': {
          'min': (15 + index * 2).toDouble(),
          'max': (25 + index * 2).toDouble(),
          'average': (20 + index * 2).toDouble(),
        },
        'weather': {
          'main': 'Clear',
          'description': 'Clear sky',
          'icon': '01d',
        },
        'details': {
          'humidity': 60 + index * 5,
          'wind_speed': 3.0 + index,
          'clouds': 10 + index * 5,
          'rain': 0.0,
          'snow': 0.0,
        },
      };
    });

    return {
      'success': true,
      'data': {
        'city': city,
        'country': 'Unknown',
        'forecast': forecast,
      },
      'timestamp': DateTime.now().toIso8601String(),
      'request_id': 'mock-forecast-id',
    };
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    // This would normally call a geocoding API
    // For now, return mock data
    final cities = [
      {'name': 'New York', 'country': 'US', 'lat': 40.7128, 'lon': -74.0060},
      {'name': 'London', 'country': 'GB', 'lat': 51.5074, 'lon': -0.1278},
      {'name': 'Tokyo', 'country': 'JP', 'lat': 35.6762, 'lon': 139.6503},
      {'name': 'Paris', 'country': 'FR', 'lat': 48.8566, 'lon': 2.3522},
      {'name': 'Sydney', 'country': 'AU', 'lat': -33.8688, 'lon': 151.2093},
    ];

    return cities
        .where((city) => 
            city['name'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}