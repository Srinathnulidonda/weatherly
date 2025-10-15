import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class WeatherEffects extends StatelessWidget {
  final String weatherCondition;
  final AnimationController animationController;

  const WeatherEffects({
    super.key,
    required this.weatherCondition,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final condition = weatherCondition.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return _buildRainEffect(context);
    } else if (condition.contains('snow')) {
      return _buildSnowEffect(context);
    } else if (condition.contains('thunder')) {
      return _buildThunderstormEffect(context);
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return _buildFogEffect(context);
    } else if (condition.contains('cloud')) {
      return _buildCloudEffect(context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildRainEffect(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(60, (index) {
          return Positioned(
            left: (index * 25.0) % MediaQuery.of(context).size.width,
            top: -30,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final progress = (animationController.value + index * 0.1) % 1.0;
                final y = progress * (MediaQuery.of(context).size.height + 60) - 30;
                final opacity = math.max(0.3, math.min(0.8, 1.0 - (progress * 0.5)));
                
                return Transform.translate(
                  offset: Offset(
                    math.sin(progress * 6.28) * 10, // Slight horizontal movement
                    y,
                  ),
                  child: Container(
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.lightBlue.withOpacity(opacity),
                          Colors.blue.withOpacity(opacity * 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSnowEffect(BuildContext context) {
    final snowflakes = ['❄', '❅', '❆', '•', '⋅'];
    
    return IgnorePointer(
      child: Stack(
        children: List.generate(40, (index) {
          return Positioned(
            left: (index * 30.0) % MediaQuery.of(context).size.width,
            top: -50,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final progress = (animationController.value + index * 0.05) % 1.0;
                final y = progress * (MediaQuery.of(context).size.height + 100) - 50;
                final swayX = 30 * math.sin(progress * 6.28 + index);
                final rotation = progress * 360 + index * 30;
                final size = 8.0 + (index % 4) * 4.0;
                final opacity = math.max(0.4, math.min(0.9, 1.0 - (progress * 0.3)));
                
                return Transform.translate(
                  offset: Offset(swayX, y),
                  child: Transform.rotate(
                    angle: rotation * math.pi / 180,
                    child: Text(
                      snowflakes[index % snowflakes.length],
                      style: TextStyle(
                        fontSize: size,
                        color: Colors.white.withOpacity(opacity),
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildThunderstormEffect(BuildContext context) {
    return Stack(
      children: [
        // Rain effect
        _buildRainEffect(context),
        
        // Lightning flashes
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final lightningTrigger = (animationController.value * 10) % 1.0;
            final shouldFlash = lightningTrigger > 0.95;
            
            if (!shouldFlash) return const SizedBox.shrink();
            
            return IgnorePointer(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 2.0,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.blue.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Lightning bolts
        ...List.generate(3, (index) {
          return Positioned(
            left: (index * 150.0) % MediaQuery.of(context).size.width,
            top: 0,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final lightningTrigger = (animationController.value * 5 + index) % 1.0;
                final shouldShow = lightningTrigger > 0.98;
                
                if (!shouldShow) return const SizedBox.shrink();
                
                return IgnorePointer(
                  child: CustomPaint(
                    size: Size(4, MediaQuery.of(context).size.height * 0.6),
                    painter: LightningPainter(),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFogEffect(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(5, (layerIndex) {
          return Positioned.fill(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final progress = (animationController.value + layerIndex * 0.2) % 1.0;
                final translateX = progress * MediaQuery.of(context).size.width * 0.5;
                
                return Transform.translate(
                  offset: Offset(translateX - MediaQuery.of(context).size.width * 0.25, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.1 + layerIndex * 0.05),
                          Colors.white.withOpacity(0.15 + layerIndex * 0.05),
                          Colors.white.withOpacity(0.1 + layerIndex * 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20 + layerIndex * 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCloudEffect(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(8, (index) {
          return Positioned(
            left: (index * 80.0) % (MediaQuery.of(context).size.width + 200) - 100,
            top: (index * 40.0) % (MediaQuery.of(context).size.height * 0.6),
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final progress = (animationController.value + index * 0.1) % 1.0;
                final translateX = progress * (MediaQuery.of(context).size.width + 400) - 200;
                final scale = 0.5 + (index % 3) * 0.3;
                final opacity = 0.1 + (index % 2) * 0.1;
                
                return Transform.translate(
                  offset: Offset(translateX, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: CustomPaint(
                      size: const Size(120, 60),
                      painter: CloudPainter(opacity: opacity),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class LightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final random = math.Random(42); // Fixed seed for consistent lightning
    
    path.moveTo(size.width * 0.5, 0);
    
    double currentX = size.width * 0.5;
    double currentY = 0;
    
    while (currentY < size.height) {
      final segmentLength = 20 + random.nextDouble() * 40;
      final angleVariation = (random.nextDouble() - 0.5) * 0.8;
      
      currentX += math.sin(angleVariation) * 15;
      currentY += segmentLength;
      
      // Keep within bounds
      currentX = math.max(0, math.min(size.width, currentX));
      
      path.lineTo(currentX, currentY);
      
      // Add branches occasionally
      if (random.nextDouble() > 0.7 && currentY > size.height * 0.3) {
        final branchPath = Path();
        branchPath.moveTo(currentX, currentY);
        branchPath.lineTo(
          currentX + (random.nextDouble() - 0.5) * 60,
          currentY + 20 + random.nextDouble() * 30,
        );
        canvas.drawPath(branchPath, paint..strokeWidth = 1.5);
      }
    }
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CloudPainter extends CustomPainter {
  final double opacity;

  CloudPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Main cloud body
    final cloudPath = Path();
    
    // Create cloud shape with multiple circles
    final circles = [
      {'x': size.width * 0.2, 'y': size.height * 0.6, 'r': size.width * 0.15},
      {'x': size.width * 0.4, 'y': size.height * 0.4, 'r': size.width * 0.2},
      {'x': size.width * 0.6, 'y': size.height * 0.5, 'r': size.width * 0.18},
      {'x': size.width * 0.8, 'y': size.height * 0.65, 'r': size.width * 0.12},
    ];

    for (final circle in circles) {
      canvas.drawCircle(
        Offset(circle['x']! as double, circle['y']! as double),
        circle['r']! as double,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => 
      oldDelegate is CloudPainter && oldDelegate.opacity != opacity;
}