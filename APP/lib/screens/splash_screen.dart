import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import '../utils/theme_manager.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _heroController;
  late AnimationController _atmosphereController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  
  // Complex Animations
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;
  late Animation<double> _iconElevation;
  late Animation<double> _glowIntensity;
  late Animation<double> _atmosphereOpacity;
  late Animation<double> _textFade;
  late Animation<double> _textSpacing;
  late Animation<double> _progressWidth;
  
  // State
  bool _isExiting = false;
  double _actualProgress = 0.0;
  String _loadingStatus = '';
  Timer? _progressTimer;
  List<_WeatherParticle> particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startMasterSequence();
  }

  void _initializeAnimations() {
    // Hero animation controller (main sequence)
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Atmosphere effects
    _atmosphereController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Icon entrance with sophisticated curve
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_heroController);

    // Subtle rotation
    _iconRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.02),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.02, end: 0.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    // Elevation effect
    _iconElevation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    ));

    // Glow intensity
    _glowIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.6),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.1, 0.7),
    ));

    // Atmosphere
    _atmosphereOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    // Text animations
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    ));

    _textSpacing = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    // Progress bar
    _progressWidth = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      particles.add(_WeatherParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.5,
        opacity: random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  void _startMasterSequence() async {
    // Start animations
    await Future.delayed(const Duration(milliseconds: 100));
    _heroController.forward();
    
    // Shimmer effect after text appears
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _shimmerController.repeat();
      }
    });

    // Simulate realistic loading
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Non-linear progress for realistic feel
        final targetProgress = _progressWidth.value;
        final diff = targetProgress - _actualProgress;
        _actualProgress += diff * 0.1; // Smooth easing

        // Update status based on progress
        if (_actualProgress < 0.25) {
          _loadingStatus = 'Initializing';
        } else if (_actualProgress < 0.5) {
          _loadingStatus = 'Connecting to satellites';
        } else if (_actualProgress < 0.75) {
          _loadingStatus = 'Fetching weather data';
        } else if (_actualProgress < 0.95) {
          _loadingStatus = 'Analyzing conditions';
        } else {
          _loadingStatus = 'Ready';
          timer.cancel();
          _completeLoading();
        }
      });
    });
  }

  void _completeLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && !_isExiting) {
      _exitToHome();
    }
  }

  void _exitToHome() async {
    setState(() => _isExiting = true);
    HapticFeedback.lightImpact();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 1.05,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // Premium gradient mesh background
          _buildPremiumBackground(),
          
          // Atmospheric particles
          _buildParticleSystem(),
          
          // Main content with glass layer
          _buildGlassLayer(),
          
          // Logo and branding
          _buildCenterContent(),
          
          // Premium exit transition
          _buildExitTransition(),
        ],
      ),
    );
  }

  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_atmosphereController, _pulseController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_atmosphereController.value * math.pi * 2) * 0.3,
                math.cos(_atmosphereController.value * math.pi * 2) * 0.3 - 0.2,
              ),
              radius: 1.5 + (_pulseController.value * 0.1),
              colors: [
                const Color(0xFF1E3C72),
                const Color(0xFF2A5298),
                const Color(0xFF0A0E27),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _atmosphereController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlesPainter(
            particles: particles,
            progress: _atmosphereController.value,
            opacity: _atmosphereOpacity.value,
          ),
        );
      },
    );
  }

  Widget _buildGlassLayer() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _atmosphereOpacity.value * 0.3,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.white.withOpacity(0.01),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            
            // Premium animated icon
            _buildHeroIcon(),
            
            const SizedBox(height: 80),
            
            // Brand identity
            _buildBrandSection(),
            
            const Spacer(flex: 2),
            
            // Loading section
            _buildLoadingSection(),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

Widget _buildHeroIcon() {
  return AnimatedBuilder(
    animation: _heroController,
    builder: (context, child) {
      return Transform.scale(
        scale: _iconScale.value,
        child: Transform.rotate(
          angle: _iconRotation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                // Glow effect
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4 * _glowIntensity.value),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
                // Elevation shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: _iconElevation.value,
                  offset: Offset(0, _iconElevation.value * 0.5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF60A5FA),
                    Color(0xFF3B82F6),
                    Color(0xFF2563EB),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Stack(
                children: [
                  // Glass overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  // Icon content
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated sun
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.9 + (_pulseController.value * 0.1),
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                size: 60,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            );
                          },
                        ),
                        // Cloud overlay with delay
                        if (_iconScale.value > 0.5)
                          Transform.translate(
                            offset: const Offset(15, 15),
                            child: Icon(
                              Icons.cloud_rounded,
                              size: 45,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ).animate()
                            .fadeIn(delay: 800.ms, duration: 600.ms)
                            .slideX(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
  Widget _buildBrandSection() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _textFade.value,
          child: Column(
            children: [
              // App name with premium typography
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.5),
                          Colors.white,
                        ],
                        stops: [
                          _shimmerController.value - 0.3,
                          _shimmerController.value,
                          _shimmerController.value + 0.3,
                        ].map((e) => e.clamp(0.0, 1.0)).toList(),
                      ).createShader(bounds);
                    },
                    child: Text(
                      'WEATHERLY',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w200,
                        letterSpacing: _textSpacing.value + 3,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Animated divider
              Container(
                width: 80 * _textFade.value,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tagline
              Text(
                'Premium Weather Intelligence',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _progressWidth.value > 0 ? 1.0 : 0.0,
          child: Column(
            children: [
              // Premium progress bar
              Container(
                width: 240,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Stack(
                    children: [
                      // Actual progress
                      FractionallySizedBox(
                        widthFactor: _actualProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF60A5FA),
                                Color(0xFF3B82F6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Shimmer effect
                      if (_actualProgress > 0 && _actualProgress < 1)
                        FractionallySizedBox(
                          widthFactor: _actualProgress.clamp(0.0, 1.0),
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: [
                                      (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                                      _shimmerController.value.clamp(0.0, 1.0),
                                      (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _loadingStatus,
                  key: ValueKey(_loadingStatus),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExitTransition() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isExiting 
            ? Colors.white.withOpacity(1.0)
            : Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    _atmosphereController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }
}

// Data class for particles
class _WeatherParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _WeatherParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Custom painter for particle system
class _ParticlesPainter extends CustomPainter {
  final List<_WeatherParticle> particles;
  final double progress;
  final double opacity;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final y = ((particle.y + progress * particle.speed) % 1.0) * size.height;
      final x = particle.x * size.width + 
                math.sin(progress * math.pi * 2 + particle.x * 10) * 20;
      
      paint.color = Colors.white.withOpacity(particle.opacity * opacity);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}