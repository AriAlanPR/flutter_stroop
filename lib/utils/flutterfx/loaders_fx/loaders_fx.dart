import 'dart:math' as math;
import 'package:stroop/utils/flutterfx/app_pallet.dart';
import 'package:flutter/material.dart';
import 'package:stroop/utils/flutterfx/loaders_fx/animations/animation_strategy.dart';

// Step 3: Main widget that uses the strategy
class AnimatedAvatarRow extends StatefulWidget {
  final int numberOfAvatars;
  final double avatarSize;
  final double overlapFactor;
  final Curve animationCurve;
  final AvatarAnimationStrategy animationStrategy;
  final List<ImageProvider>? avatarImages;
  final List<IconData>? avatarIcons;
  final List<Color>? borderColors;

  const AnimatedAvatarRow({
    super.key,
    this.numberOfAvatars = 5,
    this.avatarSize = 45.0,
    this.overlapFactor = 0.6,
    this.animationCurve = Curves.easeInOut,
    required this.animationStrategy,
    this.avatarImages,
    this.avatarIcons,
    this.borderColors,
  });

  @override
  State<AnimatedAvatarRow> createState() => _AnimatedAvatarRowState();
}

class _AnimatedAvatarRowState extends State<AnimatedAvatarRow>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.numberOfAvatars,
      (index) => AnimationController(
        duration: widget.animationStrategy.getAnimationDuration(index),
        vsync: this,
      ),
    );

    _animations = List.generate(
      widget.numberOfAvatars,
      (index) => Tween<double>(
        begin: 0.0,
        end: math.pi * 2,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: widget.animationCurve,
        ),
      ),
    );

    for (int i = 0; i < widget.numberOfAvatars; i++) {
      Future.delayed(
        widget.animationStrategy.getAnimationDelay(i, widget.numberOfAvatars),
        () {
          if (mounted) {
            _controllers[i].repeat(
              reverse: widget.animationStrategy.shouldReverseAnimation,
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAvatar(int index) {
    // Prefer icons over images if provided
    final hasIcon =
        widget.avatarIcons != null && index < widget.avatarIcons!.length;

    return Container(
      width: widget.avatarSize,
      height: widget.avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppPallet.appBarLight.withValues(alpha: 0.9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ClipOval(
          // Render a solid blue circle as the base. If an icon is provided,
          // show it centered in white. Default (no icon) is just a blue circle.
          child: Container(
            color: AppPallet.appBarLight,
            alignment: Alignment.center,
            child: hasIcon
                ? Icon(
                    widget.avatarIcons![index],
                    color: AppPallet.appBarLight,
                    size: widget.avatarSize * 0.5, // proportional sizing
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rowWidth = widget.avatarSize +
        (widget.avatarSize *
            (1 - widget.overlapFactor) *
            (widget.numberOfAvatars - 1));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: rowWidth,
        height: widget.avatarSize + 24.0, // Account for animation displacement
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(
            widget.numberOfAvatars,
            (index) {
              return Positioned(
                left: index * (widget.avatarSize * (1 - widget.overlapFactor)),
                child: AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return widget.animationStrategy.buildAnimatedAvatar(
                      child: child!,
                      animation: _animations[index],
                      index: index,
                    );
                  },
                  child: _buildAvatar(index),
                ),
              );
            },
          ).reversed.toList(),
        ),
      ),
    );
  }
}