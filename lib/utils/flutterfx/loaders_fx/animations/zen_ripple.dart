import 'dart:math';
import 'package:vector_math/vector_math_64.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';
import 'package:flutter/material.dart';

// Strategy 4: Zen Ripple Animation
class ZenRipple extends AvatarAnimationStrategy {
  final Duration animationDuration;
  final Duration staggerDelay;
  final double maxRotation;
  final double maxTranslation;

  ZenRipple({
    this.animationDuration = const Duration(milliseconds: 2500),
    this.staggerDelay = const Duration(milliseconds: 250),
    this.maxRotation = pi / 4,
    this.maxTranslation = 25.0,
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
    final rotateZ = sin(value * pi) * maxRotation;
    final translateY = sin(value * pi) * maxTranslation;
    final perspective = 0.002 * sin(value * pi);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, perspective)
        ..rotateZ(rotateZ)
        ..translateByVector3(Vector3(0.0, translateY, 0.0)),
      alignment: Alignment.center,
      child: child,
    );
  }
}
