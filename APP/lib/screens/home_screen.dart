import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/weather_service.dart';
import '../utils/theme_manager.dart';
import '../utils/notification_manager.dart';
import '../utils/weather_effects.dart';
import '../utils/saved_locations_manager.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final SavedLocationsManager _locationsManager = SavedLocationsManager();
  
  late AnimationController _animationController;
  late AnimationController _refreshController;
  late AnimationController _backgroundController;
  
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecastData;
  List<Map<String, dynamic>> _savedLocations = [];
  bool _isLoading = true;
  String _currentCity = '';
  String _temperatureUnit = 'metric';
  String _windUnit = 'metric';
  bool _isRefreshing = false;
  bool _animationsEnabled = true;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSettings();
    _loadSavedLocations();
    _loadWeatherData();
    _updateDateTime();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _temperatureUnit = prefs.getString('temperature_unit') ?? 'metric';
      _windUnit = prefs.getString('wind_unit') ?? 'metric';
      _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _loadSavedLocations() async {
    final locations = await _locationsManager.getSavedLocations();
    setState(() {
      _savedLocations = locations;
    });
  }

  Future<void> _loadWeatherData([String? city]) async {
    setState(() => _isLoading = true);
    
    try {
      final weatherData = await _weatherService.getWeatherData(city);
      final forecastData = await _weatherService.getForecastData(city);
      
      setState(() {
        _currentWeather = weatherData;
        _forecastData = forecastData;
        _currentCity = weatherData['data']['city'];
        _isLoading = false;
      });
      
      // Update theme and notifications
      final weather = weatherData['data']['weather']['main'];
      final description = weatherData['data']['weather']['description'];
      ThemeManager.updateTheme(weather, description);
      
      if (_notificationsEnabled) {
        await NotificationManager.scheduleWeatherAlert(weatherData['data']);
      }
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Unable to load weather data');
    }
  }

  Future<void> _refreshWeather() async {
    setState(() => _isRefreshing = true);
    _refreshController.forward().then((_) => _refreshController.reset());
    
    await _loadWeatherData(_currentCity);
    setState(() => _isRefreshing = false);
    
    HapticFeedback.mediumImpact();
  }

  void _updateDateTime() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_currentWeather != null) {
        final weather = _currentWeather!['data']['weather']['main'];
        final description = _currentWeather!['data']['weather']['description'];
        ThemeManager.updateTheme(weather, description);
        if (mounted) setState(() {});
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  double _convertTemperature(double temp) {
    return _temperatureUnit == 'imperial' ? (temp * 9 / 5) + 32 : temp;
  }

  double _convertWindSpeed(double speed) {
    return _windUnit == 'imperial' ? speed * 2.237 : speed * 3.6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Dynamic animated background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: ThemeManager.getCurrentGradient(_backgroundController.value),
                ),
              );
            },
          ),
          
          // Weather effects overlay
          if (_currentWeather != null && _animationsEnabled)
            WeatherEffects(
              weatherCondition: _currentWeather!['data']['weather']['main'],
              animationController: _animationController,
            ),
          
          // Main content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _currentWeather == null
                    ? _buildErrorState()
                    : _buildWeatherContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu, size: 20),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: GlassContainer(
        width: double.infinity,
        height: 44,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 15,
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(0, 1), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic)),
                      ),
                      child: child,
                    );
                  },
                ),
              );
              if (result != null) {
                _loadWeatherData(result);
              }
            },
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentCity.isEmpty ? 'Loading...' : _currentCity,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedBuilder(
              animation: _refreshController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshController.value * 2 * math.pi,
                  child: const Icon(Icons.refresh_rounded, size: 20),
                );
              },
            ),
          ),
          onPressed: _isRefreshing ? null : _refreshWeather,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.wb_sunny_rounded, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weather',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Beautiful forecasts',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white24, height: 1),
              
              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildDrawerItem(
                      Icons.my_location_rounded,
                      'Current Location',
                      () async {
                        Navigator.pop(context);
                        await _loadWeatherData();
                      },
                    ),
                    _buildDrawerItem(
                      Icons.bookmark_rounded,
                      'Saved Locations',
                      () {
                        Navigator.pop(context);
                        _showSavedLocations();
                      },
                    ),
                    _buildDrawerItem(
                      Icons.settings_rounded,
                      'Settings',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings').then((_) {
                          _loadSettings();
                        });
                      },
                    ),
                    _buildDrawerItem(
                      Icons.info_rounded,
                      'About',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ThemeManager.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: ThemeManager.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2000.ms),
          const SizedBox(height: 32),
          Text(
            'Loading weather...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Getting the latest forecast',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Weather Unavailable',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to fetch weather data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _loadWeatherData(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeManager.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildWeatherContent() {
    if (_currentWeather == null) return const SizedBox.shrink();
    
    final data = _currentWeather!['data'];
    final forecast = _forecastData?['data'];
    
    return RefreshIndicator(
      onRefresh: _refreshWeather,
      color: ThemeManager.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Current weather
            _buildCurrentWeather(data),
            
            // Hourly forecast
            if (forecast != null) _buildHourlyForecast(forecast),
            
            // Daily forecast
            if (forecast != null) _buildDailyForecast(forecast),
            
            // Weather details
            _buildWeatherDetails(data),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(Map<String, dynamic> data) {
    final temp = _convertTemperature(data['temperature']['current'].toDouble());
    final high = _convertTemperature(data['temperature']['max'].toDouble());
    final low = _convertTemperature(data['temperature']['min'].toDouble());
    final unit = _temperatureUnit == 'imperial' ? 'F' : 'C';
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '${temp.round()}°',
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w200,
              height: 1,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://openweathermap.org/img/wn/${data['weather']['icon']}@4x.png',
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 8),
              Text(
                data['weather']['description'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTempStat('↑', '${high.round()}°$unit'),
              const SizedBox(width: 32),
              _buildTempStat('↓', '${low.round()}°$unit'),
              const SizedBox(width: 32),
              _buildTempStat('💧', '${data['details']['humidity']}%'),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildTempStat(String icon, String value) {
    return Row(
      children: [
        Text(
          icon,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(Map<String, dynamic> forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat('MMMM d').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 24,
            itemBuilder: (context, index) {
              final hour = DateTime.now().add(Duration(hours: index));
              final temp = _convertTemperature(
                _currentWeather!['data']['temperature']['current'].toDouble() +
                    (5 - (index % 10)),
              );
              
              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                child: GlassContainer(
                  width: 60,
                  height: 120,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  blur: 10,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        index == 0 ? 'Now' : DateFormat('ha').format(hour),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CachedNetworkImage(
                        imageUrl: 'https://openweathermap.org/img/wn/${_currentWeather!['data']['weather']['icon']}@2x.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${temp.round()}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: 50 * index),
                duration: 600.ms,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(Map<String, dynamic> forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: forecast['forecast']?.length ?? 0,
          itemBuilder: (context, index) {
            final day = forecast['forecast'][index];
            final high = _convertTemperature(day['temperature']['max'].toDouble());
            final low = _convertTemperature(day['temperature']['min'].toDouble());
            final unit = _temperatureUnit == 'imperial' ? 'F' : 'C';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                width: double.infinity,
                height: 80,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                blur: 10,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    index == 0 ? 'Today' : day['day'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMM d').format(DateTime.parse(day['date'])),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  leading: CachedNetworkImage(
                    imageUrl: 'https://openweathermap.org/img/wn/${day['weather']['icon']}@2x.png',
                    width: 36,
                    height: 36,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${high.round()}°$unit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${low.round()}°$unit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: 600.ms,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeatherDetails(Map<String, dynamic> data) {
    final details = data['details'];
    final windSpeed = _convertWindSpeed(details['wind_speed'].toDouble());
    final windUnit = _windUnit == 'imperial' ? 'mph' : 'km/h';
    
    final detailItems = [
      {'icon': Icons.air, 'label': 'Wind', 'value': '${windSpeed.round()} $windUnit'},
      {'icon': Icons.water_drop, 'label': 'Humidity', 'value': '${details['humidity']}%'},
      {'icon': Icons.visibility, 'label': 'Visibility', 'value': '${details['visibility']}km'},
      {'icon': Icons.speed, 'label': 'Pressure', 'value': '${details['pressure']}hPa'},
      {'icon': Icons.wb_sunny, 'label': 'UV Index', 'value': '${(details['humidity'] / 10).round()}'},
      {'icon': Icons.wb_twilight, 'label': 'Sunrise', 'value': data['sun']['sunrise']},
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: detailItems.length,
        itemBuilder: (context, index) {
          final item = detailItems[index];
          final itemWidth = (MediaQuery.of(context).size.width - 32 - 24) / 3;
          return GlassContainer(
            width: itemWidth,
            height: itemWidth,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            blur: 10,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 20,
                  color: ThemeManager.primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['value'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: 100 * index),
            duration: 600.ms,
          );
        },
      ),
    );
  }

  void _showSavedLocations() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSavedLocationsSheet(),
    );
  }

  Widget _buildSavedLocationsSheet() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: GlassContainer(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 20,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Locations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                      if (result != null) {
                        await _locationsManager.saveLocation(result, 22); // Mock temp
                        _loadSavedLocations();
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            
            // Locations list
            Expanded(
              child: _savedLocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved locations',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add a location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _savedLocations.length,
                      itemBuilder: (context, index) {
                        final location = _savedLocations[index];
                        return _buildSavedLocationItem(location, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationItem(Map<String, dynamic> location, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        width: double.infinity,
        height: 72,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 10,
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              _loadWeatherData(location['name']);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${location['temperature']}°',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _locationsManager.removeLocation(location['name']);
                      _loadSavedLocations();
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}