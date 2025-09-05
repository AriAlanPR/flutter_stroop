import 'dart:math';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class CoinFlip extends AvatarAnimationStrategy {
  final Duration animationDuration;
  final Duration staggerDelay;
  final double maxHeight;
  final double perspectiveValue;
  final double rotationAngle;

  CoinFlip({
    this.animationDuration = const Duration(milliseconds: 1800),
    this.staggerDelay = const Duration(milliseconds: 120),
    this.maxHeight = 25.0,
    this.perspectiveValue = 0.002,
    this.rotationAngle = pi, // Full rotation
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

    // Calculate height parabola for smooth up-down motion
    final heightProgress = sin(value * pi);
    final height = heightProgress * maxHeight;

    // Calculate rotation with easing
    final rotationProgress = value;
    final currentRotation = rotationProgress * rotationAngle;

    // Add subtle scale effect during flip
    final scale = 1.0 + (sin(value * pi) * 0.1);

    // Add slight horizontal movement during flip
    final horizontalShift = sin(value * pi * 2) * 5.0;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, perspectiveValue) // Add perspective
        ..translateByVector3(
            Vector3(horizontalShift, -height, 0.0)) // Move up and slightly sideways
        ..rotateX(currentRotation) // Flip like a coin
        ..scaleByDouble(scale, scale, scale, 1.0), // Subtle scale animation
      alignment: Alignment.center,
      child: child,
    );
  }
}
