import 'dart:math';

import 'package:stroop/utils/flutterfx/loaders_fx/animations/breathing_space.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/coin_flip.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/coin_rotate.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/floating_meditation.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/zen_ripple.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/grid_pattern_painter.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/loaders_fx.dart';
import 'package:flutter/material.dart';

class LoaderAvatarsDemo2 extends StatelessWidget {
  const LoaderAvatarsDemo2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: GridPatternPainter(isDarkMode: true),
            size: Size.infinite,
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _DemoSection(
                    title: 'Coin',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: CoinFlip(
                        maxHeight: 25.0,
                        perspectiveValue: 0.002,
                        staggerDelay: Duration(milliseconds: 120),
                      ),
                      avatarSize: 32,
                      overlapFactor: 0.4,
                    ),
                  ),

                  SizedBox(height: 32),

                  _DemoSection(
                    title: 'Rotate',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: CoinRotate(
                        maxHeight: 25.0,
                        perspectiveValue: 0.002,
                        staggerDelay: Duration(milliseconds: 120),
                      ),
                      avatarSize: 32,
                      overlapFactor: 0.5,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Random chaotic movement
                  _DemoSection(
                    title: 'Breathing Space',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: BreathingSpace(
                        maxScale: 1.15,
                        maxDistance: 15.0,
                        animationDuration: Duration(milliseconds: 4000),
                        staggerDelay: Duration(milliseconds: 300),
                      ),
                      avatarSize: 32,
                      overlapFactor: 0.45,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Random chaotic movement
                  _DemoSection(
                    title: 'Zen ripple',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: ZenRipple(
                        maxRotation: pi / 6,
                        maxTranslation: 20.0,
                        animationDuration: Duration(milliseconds: 2500),
                        staggerDelay: Duration(milliseconds: 250),
                      ),
                      avatarSize: 32,
                      overlapFactor: 0.35,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Random chaotic movement
                  _DemoSection(
                    title: 'Floating Meditation',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: FloatingMeditation(
                        floatHeight: 15.0,
                        rotationAngle: pi / 10,
                        animationDuration: Duration(milliseconds: 3500),
                        staggerDelay: Duration(milliseconds: 180),
                      ),
                      avatarSize: 32,
                      overlapFactor: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display a demo section with title and description
class _DemoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DemoSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        child,
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}