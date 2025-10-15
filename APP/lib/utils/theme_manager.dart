import 'package:flutter/material.dart';
import 'dart:math' as math;

class ThemeManager {
  static const Color primaryColor = Color(0xFF3B82F6);
  
  static String _currentTimeOfDay = 'day';
  static String _currentWeatherCategory = 'clear';
  static DateTime _lastUpdate = DateTime.now();

  // Time periods with smooth transitions
  static final Map<String, Map<String, double>> _timeOfDay = {
    'dawn': {'start': 4.5, 'end': 6.5},
    'sunrise': {'start': 6.5, 'end': 7.5},
    'morning': {'start': 7.5, 'end': 11.5},
    'midday': {'start': 11.5, 'end': 14.5},
    'afternoon': {'start': 14.5, 'end': 17.5},
    'dusk': {'start': 17.5, 'end': 19.5},
    'night': {'start': 19.5, 'end': 4.5},
  };

  // Enhanced gradient backgrounds with more variations
  static final Map<String, Map<String, LinearGradient>> _backgrounds = {
    'dawn': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF87CEEB),
          Color(0xFFFFA07A), Color(0xFFFFB6C1)
        ],
        stops: [0.0, 0.3, 0.6, 0.8, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFD3D3D3), Color(0xFFFFB6C1), Color(0xFF87CEEB),
          Color(0xFFB0C4DE), Color(0xFFDDA0DD)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF708090), Color(0xFFFFB6C1), Color(0xFF4682B4),
          Color(0xFF5F9EA0), Color(0xFF6495ED)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2F4F4F), Color(0xFF708090), Color(0xFF696969),
          Color(0xFF36454F), Color(0xFF2C3E50)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE6E6FA), Color(0xFFF0F8FF), Color(0xFFFFFFFF),
          Color(0xFFF8F8FF), Color(0xFFE0FFFF)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFC0C0C0), Color(0xFFD3D3D3), Color(0xFFDCDCDC),
          Color(0xFFE5E5E5), Color(0xFFF0F0F0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
    'sunrise': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF8C00), Color(0xFFFFD700), Color(0xFF87CEEB),
          Color(0xFFFF7F50), Color(0xFFFFA500)
        ],
        stops: [0.0, 0.3, 0.6, 0.8, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFCD853F), Color(0xFFF0E68C), Color(0xFFB0C4DE),
          Color(0xFFDDA0DD), Color(0xFFF5DEB3)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8B7355), Color(0xFFD2B48C), Color(0xFF778899),
          Color(0xFF708090), Color(0xFF696969)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4B4B4D), Color(0xFF8B7D6B), Color(0xFF696969),
          Color(0xFF36454F), Color(0xFF2F4F4F)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFE4E1), Color(0xFFFFF0F5), Color(0xFFF0FFFF),
          Color(0xFFF5F5F5), Color(0xFFFFFFFF)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFDEB887), Color(0xFFF5DEB3), Color(0xFFE0E0E0),
          Color(0xFFD3D3D3), Color(0xFFC0C0C0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
    'morning': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF00BFFF), Color(0xFF87CEEB), Color(0xFF87CEFA),
          Color(0xFF6495ED), Color(0xFF4169E1)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4682B4), Color(0xFFB0C4DE), Color(0xFFD3D3D3),
          Color(0xFF87CEEB), Color(0xFF5F9EA0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2F4F4F), Color(0xFF708090), Color(0xFF778899),
          Color(0xFF696969), Color(0xFF36454F)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF191970), Color(0xFF2F4F4F), Color(0xFF483D8B),
          Color(0xFF000080), Color(0xFF191970)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFB0E0E6), Color(0xFFE0FFFF), Color(0xFFF0FFFF),
          Color(0xFFFFFFFF), Color(0xFFF5F5F5)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFA9A9A9), Color(0xFFC0C0C0), Color(0xFFD3D3D3),
          Color(0xFFDCDCDC), Color(0xFFE0E0E0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
    'midday': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E90FF), Color(0xFF00BFFF), Color(0xFF87CEEB),
          Color(0xFF4169E1), Color(0xFF0066CC)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5F9EA0), Color(0xFF87CEEB), Color(0xFFB0C4DE),
          Color(0xFF4682B4), Color(0xFF5F9EA0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF36454F), Color(0xFF708090), Color(0xFF8B9DC3),
          Color(0xFF778899), Color(0xFF2F4F4F)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1C1C1C), Color(0xFF36454F), Color(0xFF4B0082),
          Color(0xFF191970), Color(0xFF000000)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFADD8E6), Color(0xFFE0FFFF), Color(0xFFFFFFFF),
          Color(0xFFF0FFFF), Color(0xFFE6E6FA)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFB0B0B0), Color(0xFFD0D0D0), Color(0xFFE0E0E0),
          Color(0xFFC0C0C0), Color(0xFFD3D3D3)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
    'afternoon': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4169E1), Color(0xFF6495ED), Color(0xFF87CEEB),
          Color(0xFF5F9EA0), Color(0xFF4682B4)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6B8E23), Color(0xFF9ACD32), Color(0xFFB0C4DE),
          Color(0xFF87CEEB), Color(0xFF5F9EA0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3B3C36), Color(0xFF696969), Color(0xFF808080),
          Color(0xFF708090), Color(0xFF36454F)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1B1B1B), Color(0xFF3B3C36), Color(0xFF483D8B),
          Color(0xFF2F4F4F), Color(0xFF191970)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9AC0CD), Color(0xFFCAE1FF), Color(0xFFF0F8FF),
          Color(0xFFE0FFFF), Color(0xFFFFFFFF)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFA8A8A8), Color(0xFFC8C8C8), Color(0xFFD8D8D8),
          Color(0xFFD0D0D0), Color(0xFFE0E0E0)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
    'dusk': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF4500), Color(0xFFFF6347), Color(0xFFFFB6C1),
          Color(0xFFDC143C), Color(0xFFB22222)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8B4513), Color(0xFFCD853F), Color(0xFFDEB887),
          Color(0xFFD2691E), Color(0xFF8B4513)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF483D8B), Color(0xFF6A5ACD), Color(0xFF9370DB),
          Color(0xFF4B0082), Color(0xFF191970)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF191970), Color(0xFF483D8B), Color(0xFF4B0082),
          Color(0xFF2F4F4F), Color(0xFF000000)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9370DB), Color(0xFFDDA0DD), Color(0xFFEE82EE),
          Color(0xFFE6E6FA), Color(0xFFF8F8FF)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF696969), Color(0xFF808080), Color(0xFFA9A9A9),
          Color(0xFFC0C0C0), Color(0xFFD3D3D3)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
    'night': {
      'clear': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000428), Color(0xFF004e92), Color(0xFF191970),
          Color(0xFF0F0F23), Color(0xFF1A1A2E)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'cloudy': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F0F0F), Color(0xFF2F2F2F), Color(0xFF4F4F4F),
          Color(0xFF1C1C1C), Color(0xFF36454F)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'rain': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000000), Color(0xFF191970), Color(0xFF000080),
          Color(0xFF0B0B0F), Color(0xFF1C1C3A)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'thunderstorm': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000000), Color(0xFF1C1C1C), Color(0xFF2F4F4F),
          Color(0xFF0A0A0A), Color(0xFF2C2C54)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'snow': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF191970), Color(0xFF4B0082), Color(0xFF6A0DAD),
          Color(0xFF2E2E5A), Color(0xFF483D8B)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
      'fog': const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1C1C1C), Color(0xFF2F2F2F), Color(0xFF3F3F3F),
          Color(0xFF2A2A2A), Color(0xFF404040)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    },
  };

  static Future<void> initialize() async {
    _updateTimeOfDay();
  }

  static String _getTimeOfDay() {
    final hour = DateTime.now().hour + DateTime.now().minute / 60.0;
    
    for (final entry in _timeOfDay.entries) {
      final period = entry.key;
      final times = entry.value;
      
      if (period == 'night') {
        if (hour >= times['start']! || hour < times['end']!) {
          return period;
        }
      } else {
        if (hour >= times['start']! && hour < times['end']!) {
          return period;
        }
      }
    }
    return 'day';
  }

  static String _getWeatherCategory(String? condition) {
    if (condition == null) return 'clear';
    
    final lowerCondition = condition.toLowerCase();
    
    final categoryMap = {
      'clear': ['clear', 'sunny'],
      'cloudy': ['cloudy', 'partly cloudy', 'overcast', 'clouds', 'scattered clouds', 'broken clouds'],
      'rain': ['rain', 'drizzle', 'showers', 'light rain', 'moderate rain', 'heavy rain'],
      'thunderstorm': ['thunderstorm', 'thunder', 'lightning'],
      'snow': ['snow', 'sleet', 'blizzard', 'light snow', 'heavy snow'],
      'fog': ['fog', 'mist', 'haze', 'smoke']
    };

    for (final entry in categoryMap.entries) {
      if (entry.value.any((keyword) => lowerCondition.contains(keyword))) {
        return entry.key;
      }
    }
    
    return 'clear';
  }

  static void _updateTimeOfDay() {
    _currentTimeOfDay = _getTimeOfDay();
    _lastUpdate = DateTime.now();
  }

  static void updateTheme(String? weatherCondition, String? description) {
    _updateTimeOfDay();
    _currentWeatherCategory = _getWeatherCategory(weatherCondition ?? description);
  }

  static LinearGradient getCurrentGradient([double? animationValue]) {
    // Check if we need to update time of day
    if (DateTime.now().difference(_lastUpdate).inMinutes > 5) {
      _updateTimeOfDay();
    }

    LinearGradient baseGradient = _backgrounds[_currentTimeOfDay]?[_currentWeatherCategory] ??
                                  _backgrounds['day']!['clear']!;

    // Add subtle animation to gradient if animationValue is provided
    if (animationValue != null) {
      baseGradient = _animateGradient(baseGradient, animationValue);
    }

    return baseGradient;
  }

  static LinearGradient _animateGradient(LinearGradient gradient, double animationValue) {
    // Slightly shift colors for subtle animation
    final shiftAmount = math.sin(animationValue * 2 * math.pi) * 0.02;
    
    final newStops = gradient.stops?.map((stop) {
      return math.max(0.0, math.min(1.0, stop + shiftAmount));
    }).toList();

    return LinearGradient(
      begin: gradient.begin,
      end: gradient.end,
      colors: gradient.colors,
      stops: newStops,
    );
  }

  static LinearGradient getGradientForCondition(String timeOfDay, String weather) {
    return _backgrounds[timeOfDay]?[weather] ??
           _backgrounds['day']!['clear']!;
  }

  // Get complementary colors for UI elements
  static Color getTextColorForBackground() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return Colors.white.withOpacity(0.9);
    } else {
      return Colors.white.withOpacity(0.95);
    }
  }

  static Color getAccentColorForWeather(String weather) {
    switch (weather.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return const Color(0xFF4FC3F7);
      case 'snow':
        return const Color(0xFFE1F5FE);
      case 'thunderstorm':
        return const Color(0xFF9C27B0);
      case 'fog':
      case 'mist':
        return const Color(0xFF90A4AE);
      case 'cloudy':
        return const Color(0xFF78909C);
      default:
        return primaryColor;
    }
  }
}