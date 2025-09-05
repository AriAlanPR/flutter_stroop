import 'dart:math';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';
import 'package:flutter/material.dart';

// Strategy 2: Gentle Orbit Animation
class OrbitAnimation extends AvatarAnimationStrategy {
  final Duration animationDuration;
  final Duration staggerDelay;
  final double orbitRadius;
  final double maxRotation;

  OrbitAnimation({
    this.animationDuration = const Duration(milliseconds: 3000),
    this.staggerDelay = const Duration(milliseconds: 200),
    this.orbitRadius = 15.0,
    this.maxRotation = pi / 6,
  });

  @override
  Duration getAnimationDuration(int index) => animationDuration;

  @override
  Duration getAnimationDelay(int index, int totalAvatars) =>
      staggerDelay * index;

  @override
  bool get shouldReverseAnimation => false;

  @override
  Widget buildAnimatedAvatar({
    required Widget child,
    required Animation<double> animation,
    required int index,
  }) {
    final value = animation.value;
    final angle = value * 2 * pi;
    final x = cos(angle) * orbitRadius;
    final z = sin(angle) * orbitRadius;
    final rotateY = sin(angle) * maxRotation;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translateByVector3(vmath.Vector3(x, 0, z))
        ..rotateY(rotateY),
      alignment: Alignment.center,
      child: child,
    );
  }
}