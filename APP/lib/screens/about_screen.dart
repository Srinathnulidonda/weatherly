import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../utils/theme_manager.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _particleController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic background
          Container(
            decoration: BoxDecoration(
              gradient: ThemeManager.getCurrentGradient(),
            ),
          ),
          
          // Floating particles
          ..._buildFloatingParticles(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  _buildFeaturesSection(),
                  const SizedBox(height: 32),
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  _buildTechSection(),
                  const SizedBox(height: 32),
                  _buildAttributionSection(),
                  const SizedBox(height: 32),
                  _buildDeveloperSection(),
                  const SizedBox(height: 32),
                  _buildContactSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(15, (index) {
      return Positioned(
        left: (index * 50.0) % MediaQuery.of(context).size.width,
        top: (index * 80.0) % MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                20 * math.sin(_particleController.value * 2 * math.pi + index),
                30 * math.cos(_particleController.value * 2 * math.pi + index),
              ),
              child: Container(
                width: 4 + (index % 3) * 2.0,
                height: 4 + (index % 3) * 2.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1 + (index % 3) * 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 10 * math.sin(_floatingController.value * math.pi)),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            );
          },
        ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        ),
        
        const SizedBox(height: 24),
        
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFF3B82F6)],
          ).createShader(bounds),
          child: const Text(
            'Weather',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'Beautiful Weather Forecasts',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 400.ms),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.label_rounded,
                size: 16,
                color: Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms).scale(),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.thermostat_rounded,
        'title': 'Real-time Weather',
        'description': 'Accurate, up-to-the-minute conditions with automatic updates',
      },
      {
        'icon': Icons.calendar_view_week_rounded,
        'title': '7-Day Forecast',
        'description': 'Plan your week with detailed daily forecasts and trends',
      },
      {
        'icon': Icons.schedule_rounded,
        'title': 'Hourly Updates',
        'description': 'Track weather changes throughout the day with precision',
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Dynamic Themes',
        'description': 'Beautiful backgrounds that adapt to weather and time',
      },
      {
        'icon': Icons.animation_rounded,
        'title': 'Weather Effects',
        'description': 'Immersive animations for rain, snow, and more',
      },
      {
        'icon': Icons.mobile_friendly_rounded,
        'title': 'Native Experience',
        'description': 'Smooth performance optimized for mobile devices',
      },
    ];

    return _buildSection(
      'Features',
      Icons.star_rounded,
      Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return _buildFeatureCard(feature, index);
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        width: double.infinity,
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
        blur: 15,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeManager.primaryColor.withOpacity(0.3),
                      ThemeManager.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  size: 28,
                  color: ThemeManager.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.3, end: 0);
  }

  Widget _buildStatsSection() {
    final stats = [
      {'number': '200K+', 'label': 'Cities'},
      {'number': '50M+', 'label': 'API Calls'},
      {'number': '99.9%', 'label': 'Uptime'},
      {'number': '<200ms', 'label': 'Response'},
    ];

    return _buildSection(
      'By the Numbers',
      Icons.bar_chart_rounded,
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return GlassContainer(
            width: double.infinity,
            height: 100,
            gradient: LinearGradient(
              colors: [
                ThemeManager.primaryColor.withOpacity(0.1),
                ThemeManager.primaryColor.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                ThemeManager.primaryColor.withOpacity(0.3),
                ThemeManager.primaryColor.withOpacity(0.1),
              ],
            ),
            blur: 15,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                  ).createShader(bounds),
                  child: Text(
                    stat['number']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 150 * index)).scale();
        },
      ),
    );
  }

  Widget _buildTechSection() {
    final technologies = [
      {'name': 'Flutter', 'icon': '🚀'},
      {'name': 'Dart', 'icon': '💙'},
      {'name': 'Material 3', 'icon': '🎨'},
      {'name': 'OpenWeatherMap', 'icon': '🌤️'},
      {'name': 'REST API', 'icon': '⚡'},
      {'name': 'Native Performance', 'icon': '📱'},
    ];

    return _buildSection(
      'Technology',
      Icons.code_rounded,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Built with modern technologies for optimal performance across all devices.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: technologies.map((tech) => _buildTechChip(tech)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(Map<String, String> tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tech['icon']!,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            tech['name']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributionSection() {
    return _buildSection(
      'Powered By',
      Icons.cloud_rounded,
      GlassContainer(
        width: double.infinity,
        height: 200,
        gradient: LinearGradient(
          colors: [
            ThemeManager.primaryColor.withOpacity(0.1),
            ThemeManager.primaryColor.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            ThemeManager.primaryColor.withOpacity(0.3),
            ThemeManager.primaryColor.withOpacity(0.1),
          ],
        ),
        blur: 15,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.cloud_rounded,
                  size: 32,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'OpenWeatherMap',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Professional weather data from 200,000+ cities worldwide with real-time updates.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return GlassContainer(
      width: double.infinity,
      height: 400,
      gradient: LinearGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.1),
          const Color(0xFFA855F7).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.3),
          const Color(0xFFA855F7).withOpacity(0.1),
        ],
      ),
      blur: 15,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 5 * math.sin(_floatingController.value * math.pi)),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SN',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.white),
                children: [
                  const TextSpan(text: 'Developed with '),
                  WidgetSpan(
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween<double>(begin: 1.0, end: 1.3),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Text(
                            '❤️',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)),
                  ),
                  const TextSpan(text: ' by'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
              ).createShader(bounds),
              child: const Text(
                'Srinath Nulidonda',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDeveloperLink(
                  Icons.code_rounded,
                  'GitHub',
                  'https://github.com/Srinathnulidonda',
                ),
                const SizedBox(width: 16),
                _buildDeveloperLink(
                  Icons.web_rounded,
                  'Portfolio',
                  'https://srinathnulidonda.vercel.app/',
                ),
                const SizedBox(width: 16),
                _buildDeveloperLink(
                  Icons.email_rounded,
                  'Email',
                  'mailto:srinathnulidonda.dev@gmail.com',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Full-stack developer passionate about creating beautiful and functional mobile applications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildDeveloperLink(IconData icon, String label, String url) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      'Get in Touch',
      Icons.contact_support_rounded,
      Column(
        children: [
          Text(
            'Questions or feedback? We\'re here to help!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  Icons.support_agent_rounded,
                  'Support',
                  () => _launchURL('mailto:support@weatherapp.com'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  Icons.bug_report_rounded,
                  'Report Bug',
                  () => _launchURL('https://github.com/Srinathnulidonda/weather-app/issues/new'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeManager.primaryColor.withOpacity(0.8),
                ThemeManager.primaryColor.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ThemeManager.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
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
        content,
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    // Show loading indicator
    _showLoadingDialog();

    try {
      final uri = Uri.parse(url);
      
      // Debug print
      debugPrint('Attempting to launch: $url');
      
      // Try to launch the URL
      bool launched = false;
      
      // First try external application
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      
      // If external fails, try in-app webview
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      }
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (!launched) {
        throw Exception('Could not launch URL');
      }
      
      // Success haptic feedback
      HapticFeedback.lightImpact();
      
    } catch (e) {
      debugPrint('Error launching URL: $e');
      
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error dialog with options
      _showLinkOptionsDialog(url);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: GlassContainer(
          width: 120,
          height: 120,
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          blur: 20,
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _showLinkOptionsDialog(String url) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          width: double.infinity,
          height: 280,
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
                const Icon(
                  Icons.link_off_rounded,
                  size: 48,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Could not open link',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getDisplayUrl(url),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: url));
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  const Text('Link copied to clipboard'),
                                ],
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          
                          HapticFeedback.lightImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeManager.primaryColor,
                        ),
                        child: const Text('Copy Link'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayUrl(String url) {
    if (url.startsWith('mailto:')) {
      return url.substring(7); // Remove 'mailto:'
    }
    if (url.startsWith('https://')) {
      return url.substring(8); // Remove 'https://'
    }
    if (url.startsWith('http://')) {
      return url.substring(7); // Remove 'http://'
    }
    return url;
  }
}