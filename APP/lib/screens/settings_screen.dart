import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../utils/theme_manager.dart';
import '../utils/notification_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Settings values
  String _temperatureUnit = 'metric';
  String _windUnit = 'metric';
  String _pressureUnit = 'hPa';
  String _visibilityUnit = 'km';
  String _timeFormat = '12h';
  String _dateFormat = 'MM/DD/YYYY';
  String _language = 'English';
  bool _animationsEnabled = true;
  bool _uvIndexEnabled = true;
  bool _notificationsEnabled = false;
  bool _weatherAlertsEnabled = false;
  bool _autoRefreshEnabled = true;
  bool _dataOptimizationEnabled = false;
  
  // App info
  String _appVersion = '1.0.0';
  String _cacheSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadSettings();
    _calculateCacheSize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _temperatureUnit = prefs.getString('temperature_unit') ?? 'metric';
      _windUnit = prefs.getString('wind_unit') ?? 'metric';
      _pressureUnit = prefs.getString('pressure_unit') ?? 'hPa';
      _visibilityUnit = prefs.getString('visibility_unit') ?? 'km';
      _timeFormat = prefs.getString('time_format') ?? '12h';
      _dateFormat = prefs.getString('date_format') ?? 'MM/DD/YYYY';
      _language = prefs.getString('language') ?? 'English';
      _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
      _uvIndexEnabled = prefs.getBool('uv_index_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _weatherAlertsEnabled = prefs.getBool('weather_alerts_enabled') ?? false;
      _autoRefreshEnabled = prefs.getBool('auto_refresh_enabled') ?? true;
      _dataOptimizationEnabled = prefs.getBool('data_optimization_enabled') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temperature_unit', _temperatureUnit);
    await prefs.setString('wind_unit', _windUnit);
    await prefs.setString('pressure_unit', _pressureUnit);
    await prefs.setString('visibility_unit', _visibilityUnit);
    await prefs.setString('time_format', _timeFormat);
    await prefs.setString('date_format', _dateFormat);
    await prefs.setString('language', _language);
    await prefs.setBool('animations_enabled', _animationsEnabled);
    await prefs.setBool('uv_index_enabled', _uvIndexEnabled);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('weather_alerts_enabled', _weatherAlertsEnabled);
    await prefs.setBool('auto_refresh_enabled', _autoRefreshEnabled);
    await prefs.setBool('data_optimization_enabled', _dataOptimizationEnabled);
  }

  Future<void> _calculateCacheSize() async {
    // Simulate cache size calculation
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _cacheSize = '12.5 MB';
    });
  }

  Future<void> _clearCache() async {
    HapticFeedback.mediumImpact();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(
        'Clear Cache',
        'This will clear all cached weather data. You\'ll need an internet connection to fetch new data.',
        'Clear',
        Colors.orange,
      ),
    );

    if (confirmed ?? false) {
      // Show loading
      _showLoadingSnackbar('Clearing cache...');
      
      // Clear cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _loadSettings(); // Reload settings after clear
      
      // Recalculate cache size
      setState(() {
        _cacheSize = '0 MB';
      });
      
      _showSuccessSnackbar('Cache cleared successfully');
    }
  }

  Future<void> _resetSettings() async {
    HapticFeedback.heavyImpact();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(
        'Reset All Settings',
        'This will reset all settings to their default values. This action cannot be undone.',
        'Reset',
        Colors.red,
      ),
    );

    if (confirmed ?? false) {
      // Reset to defaults
      setState(() {
        _temperatureUnit = 'metric';
        _windUnit = 'metric';
        _pressureUnit = 'hPa';
        _visibilityUnit = 'km';
        _timeFormat = '12h';
        _dateFormat = 'MM/DD/YYYY';
        _language = 'English';
        _animationsEnabled = true;
        _uvIndexEnabled = true;
        _notificationsEnabled = false;
        _weatherAlertsEnabled = false;
        _autoRefreshEnabled = true;
        _dataOptimizationEnabled = false;
      });
      
      await _saveSettings();
      _showSuccessSnackbar('Settings reset to defaults');
    }
  }

  void _showLoadingSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () {
            _saveSettings();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
              child: const Icon(Icons.restore_rounded, size: 20),
            ),
            onPressed: _resetSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic background
          Container(
            decoration: BoxDecoration(
              gradient: ThemeManager.getCurrentGradient(),
            ),
          ),
          
          // Settings content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Units',
                      Icons.straighten_rounded,
                      [
                        _buildUnitSetting(
                          'Temperature',
                          Icons.thermostat_rounded,
                          _temperatureUnit,
                          ['metric', 'imperial'],
                          ['Celsius (°C)', 'Fahrenheit (°F)'],
                          (value) => setState(() => _temperatureUnit = value),
                        ),
                        _buildUnitSetting(
                          'Wind Speed',
                          Icons.air_rounded,
                          _windUnit,
                          ['metric', 'imperial'],
                          ['km/h', 'mph'],
                          (value) => setState(() => _windUnit = value),
                        ),
                        _buildUnitSetting(
                          'Pressure',
                          Icons.speed_rounded,
                          _pressureUnit,
                          ['hPa', 'inHg', 'mmHg'],
                          ['hPa', 'inHg', 'mmHg'],
                          (value) => setState(() => _pressureUnit = value),
                        ),
                        _buildUnitSetting(
                          'Visibility',
                          Icons.visibility_rounded,
                          _visibilityUnit,
                          ['km', 'mi'],
                          ['Kilometers', 'Miles'],
                          (value) => setState(() => _visibilityUnit = value),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'Display',
                      Icons.palette_rounded,
                      [
                        _buildToggleSetting(
                          'Weather Animations',
                          Icons.animation_rounded,
                          'Beautiful weather effects and animations',
                          _animationsEnabled,
                          (value) {
                            setState(() => _animationsEnabled = value);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        _buildToggleSetting(
                          'Show UV Index',
                          Icons.wb_sunny_rounded,
                          'Display UV radiation levels',
                          _uvIndexEnabled,
                          (value) {
                            setState(() => _uvIndexEnabled = value);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        _buildDropdownSetting(
                          'Time Format',
                          Icons.schedule_rounded,
                          _timeFormat,
                          ['12h', '24h'],
                          ['12-hour (AM/PM)', '24-hour'],
                          (value) => setState(() => _timeFormat = value!),
                        ),
                        _buildDropdownSetting(
                          'Date Format',
                          Icons.calendar_today_rounded,
                          _dateFormat,
                          ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                          ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                          (value) => setState(() => _dateFormat = value!),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'Notifications',
                      Icons.notifications_rounded,
                      [
                        _buildToggleSetting(
                          'Push Notifications',
                          Icons.notifications_active_rounded,
                          'Get weather updates and alerts',
                          _notificationsEnabled,
                          (value) async {
                            if (value) {
                              final granted = await _requestNotificationPermission();
                              if (granted) {
                                setState(() => _notificationsEnabled = value);
                              }
                            } else {
                              setState(() => _notificationsEnabled = value);
                            }
                            HapticFeedback.lightImpact();
                          },
                        ),
                        _buildToggleSetting(
                          'Weather Alerts',
                          Icons.warning_rounded,
                          'Severe weather warnings',
                          _weatherAlertsEnabled,
                          (value) {
                            setState(() => _weatherAlertsEnabled = value);
                            HapticFeedback.lightImpact();
                          },
                          enabled: _notificationsEnabled,
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'Data & Performance',
                      Icons.data_usage_rounded,
                      [
                        _buildToggleSetting(
                          'Auto Refresh',
                          Icons.refresh_rounded,
                          'Update weather data automatically',
                          _autoRefreshEnabled,
                          (value) {
                            setState(() => _autoRefreshEnabled = value);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        _buildToggleSetting(
                          'Data Optimization',
                          Icons.data_saver_on_rounded,
                          'Reduce data usage on mobile networks',
                          _dataOptimizationEnabled,
                          (value) {
                            setState(() => _dataOptimizationEnabled = value);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        _buildInfoTile(
                          'Cache Size',
                          Icons.storage_rounded,
                          _cacheSize,
                          onTap: _clearCache,
                          actionText: 'Clear',
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'Language & Region',
                      Icons.language_rounded,
                      [
                        _buildDropdownSetting(
                          'Language',
                          Icons.translate_rounded,
                          _language,
                          ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
                          ['English', 'Español', 'Français', 'Deutsch', '中文', '日本語'],
                          (value) => setState(() => _language = value!),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      'About',
                      Icons.info_rounded,
                      [
                        _buildInfoTile(
                          'Version',
                          Icons.verified_rounded,
                          _appVersion,
                        ),
                        _buildLinkTile(
                          'Privacy Policy',
                          Icons.privacy_tip_rounded,
                          'https://weatherly-appnow.vercel.app/privacy',
                        ),
                        _buildLinkTile(
                          'Terms of Service',
                          Icons.description_rounded,
                          'https://weatherly-appnow.vercel.app/terms',
                        ),
                        _buildLinkTile(
                          'Open Source Licenses',
                          Icons.code_rounded,
                          'https://github.com/yourusername/weatherly/blob/main/LICENSE',
                        ),
                        _buildActionTile(
                          'Rate This App',
                          Icons.star_rounded,
                          () => _rateApp(),
                        ),
                        _buildActionTile(
                          'Send Feedback',
                          Icons.feedback_rounded,
                          () => _sendFeedback(),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: ThemeManager.primaryColor),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          width: double.infinity,
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
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSetting(
    String title,
    IconData icon,
    String currentValue,
    List<String> values,
    List<String> labels,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeManager.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: ThemeManager.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: values.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final label = labels[index];
                final isSelected = currentValue == value;
                
                return GestureDetector(
                  onTap: () {
                    onChanged(value);
                    _saveSettings();
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ThemeManager.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    IconData icon,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeManager.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? ThemeManager.primaryColor
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled
                ? (newValue) {
                    onChanged(newValue);
                    _saveSettings();
                  }
                : null,
            activeColor: ThemeManager.primaryColor,
            inactiveThumbColor: Colors.white.withOpacity(0.3),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    IconData icon,
    String currentValue,
    List<String> values,
    List<String> labels,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeManager.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: ThemeManager.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: currentValue,
              items: values.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final label = labels[index];
                
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                onChanged(value);
                _saveSettings();
                HapticFeedback.lightImpact();
              },
              underline: const SizedBox.shrink(),
              dropdownColor: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              isDense: true,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    IconData icon,
    String value, {
    VoidCallback? onTap,
    String? actionText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ThemeManager.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: ThemeManager.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              if (actionText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeManager.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (onTap != null && actionText == null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.white.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkTile(String title, IconData icon, String url) {
    return _buildActionTile(
      title,
      icon,
      () => _launchURL(url),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ThemeManager.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: ThemeManager.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationDialog(
    String title,
    String message,
    String actionText,
    Color actionColor,
  ) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: GlassContainer(
        width: double.infinity,
        height: 250,
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
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 28,
                  color: actionColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(actionText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestNotificationPermission() async {
    try {
      final granted = await NotificationManager.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Please enable notifications in device settings'),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                // Open app settings
                if (Platform.isAndroid) {
                  // Android specific code to open settings
                } else if (Platform.isIOS) {
                  // iOS specific code to open settings
                }
              },
            ),
          ),
        );
      }
      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open link'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _rateApp() {
    HapticFeedback.mediumImpact();
    // Implement app rating logic
    // For Android: Google Play Store
    // For iOS: App Store
    _showSuccessSnackbar('Thank you for rating our app!');
  }

  void _sendFeedback() {
    HapticFeedback.lightImpact();
    _launchURL('mailto:support@weatherly.app?subject=Weatherly App Feedback');
  }
}