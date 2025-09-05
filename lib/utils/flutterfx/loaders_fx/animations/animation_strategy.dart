// Step 1: Define the strategy interface
import 'package:flutter/material.dart';

abstract class AvatarAnimationStrategy {
  Duration getAnimationDuration(int index);
  Duration getAnimationDelay(int index, int totalAvatars);
  bool get shouldReverseAnimation;

  Widget buildAnimatedAvatar({
    required Widget child,
    required Animation<double> animation,
    required int index,
  });
}