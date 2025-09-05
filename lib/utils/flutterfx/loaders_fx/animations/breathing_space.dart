import 'dart:math';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';
import 'package:flutter/material.dart';

// Strategy 3: Breathing Space Animation
class BreathingSpace extends AvatarAnimationStrategy {
  final Duration animationDuration;
  final Duration staggerDelay;
  final double maxScale;
  final double maxDistance;

  BreathingSpace({
    this.animationDuration = const Duration(milliseconds: 4000),
    this.staggerDelay = const Duration(milliseconds: 300),
    this.maxScale = 1.2,
    this.maxDistance = 20.0,
  });

  @override
  Duration getAnimationDuration(int index) => animationDuration;

  @override
  Duration getAnimationDelay(int index, int totalAvatars) =>
      staggerDelay * index;

  @override
  bool get shouldReverseAnimation => true;

  @override
  Widget buildAnimatedAvatar({
    required Widget child,
    required Animation<double> animation,
    required int index,
  }) {
    final value = animation.value;
    final scale = 1.0 + (sin(value * pi) * (maxScale - 1.0));
    final distance = sin(value * pi) * maxDistance;

    return Transform(
      transform: Matrix4.translationValues(0.0, 0.0, distance)
        ..scaleByDouble(scale, scale, scale, 1.0),
      alignment: Alignment.center,
      child: child,
    );
  }
}
