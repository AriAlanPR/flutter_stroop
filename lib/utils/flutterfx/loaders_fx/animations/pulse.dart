import 'dart:math';

import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';
import 'package:flutter/material.dart';

class PulseAnimation extends AvatarAnimationStrategy {
  /// The duration of the pulse animation. This is the total time it takes for one pulse to complete.
  final Duration animationDuration;

  /// The base scale of the avatars. This is the scale of the avatar when the animation is not running.
  final double baseScale;

  /// The amount by which the avatar will scale up and down during the pulse animation.
  final double scaleAmount;

  /// The width of the pulse wave. This affects how wide the scaling effect is. A higher value will make the scaling effect wider.
  final double waveWidth;

  /// The factor by which the phase of the pulse animation is shifted. This affects how quickly the animation progresses. A higher value will make the animation progress faster.
  final double phaseShiftFactor;

  PulseAnimation({
    this.animationDuration = const Duration(milliseconds: 800),
    this.baseScale = 1.0,
    this.scaleAmount = 0.3,
    this.waveWidth = 1.0,
    this.phaseShiftFactor = 0.35,
  });

  @override
  Duration getAnimationDuration(int index) => animationDuration;

  @override
  Duration getAnimationDelay(int index, int totalAvatars) => Duration.zero;

  @override
  bool get shouldReverseAnimation => true;

  @override
  Widget buildAnimatedAvatar({
    required Widget child,
    required Animation<double> animation,
    required int index,
  }) {
    final scale = _calculatePulseScale(animation.value, index);
    return Transform.scale(
      scale: scale,
      child: child,
    );
  }

  double _calculatePulseScale(double animationValue, int index) {
    final phaseShift = index * phaseShiftFactor;
    double shiftedValue = animationValue - phaseShift;
    while (shiftedValue < 0) {
      shiftedValue += pi * 2;
    }

    double normalizedSine = (sin(shiftedValue) + 1) / 2;
    normalizedSine = pow(normalizedSine, 1 / waveWidth) as double;

    return baseScale + normalizedSine * scaleAmount;
  }
}