import 'package:stroop/utils/flutterfx/loaders_fx/animations/pulse.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/random_animation.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/ripple.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/wave.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/grid_pattern_painter.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/loaders_fx.dart';
import 'package:flutter/material.dart';

class LoaderAvatarsDemo extends StatelessWidget {
  const LoaderAvatarsDemo({super.key});

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
                    title: 'Pulse',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: PulseAnimation(
                        scaleAmount: 0.6,
                        waveWidth: 0.1,
                        phaseShiftFactor: 0.6,
                      ),
                      avatarSize: 32,
                      overlapFactor: 0.4,
                    ),
                  ),

                  SizedBox(height: 32),

                  _DemoSection(
                    title: 'Wave',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 6,
                      animationStrategy: WaveAnimation(),
                      avatarSize: 32,
                      overlapFactor: 0.3,
                    ),
                  ),

                  SizedBox(height: 32),
                  _DemoSection(
                    title: 'Ripple',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: RippleAnimation(),
                      avatarSize: 32,
                      overlapFactor: 0.4,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Random chaotic movement
                  _DemoSection(
                    title: 'Random',
                    child: AnimatedAvatarRow(
                      numberOfAvatars: 8,
                      animationStrategy: RandomAnimation(),
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