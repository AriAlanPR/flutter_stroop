import 'dart:math';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

// Strategy 5: Floating Meditation Animation
class FloatingMeditation extends AvatarAnimationStrategy {
  final Duration animationDuration;
  final Duration staggerDelay;
  final double floatHeight;
  final double rotationAngle;

  FloatingMeditation({
    this.animationDuration = const Duration(milliseconds: 3500),
    this.staggerDelay = const Duration(milliseconds: 180),
    this.floatHeight = 18.0,
    this.rotationAngle = pi / 8,
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
    final height = sin(value * 2 * pi) * floatHeight;
    final rotate = sin(value * 2 * pi) * rotationAngle;
    final scale = 1.0 + (sin(value * 2 * pi) * 0.1);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translateByVector3(Vector3(0.0, -height, 0.0))
        ..rotateZ(rotate)
        ..scaleByDouble(scale, scale, scale, 1.0),
      alignment: Alignment.center,
      child: child,
    );
  }
}