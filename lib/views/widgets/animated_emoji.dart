import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedEmoji extends StatefulWidget {
  final String emoji;
  const AnimatedEmoji({super.key, required this.emoji});

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    final duration = Duration(milliseconds: 1500 + _random.nextInt(3500));
    final offsetX = (_random.nextDouble() - 0.5) * 0.3;
    final offsetY = (_random.nextDouble() - 0.5) * 0.3;

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    Future.delayed(Duration(milliseconds: _random.nextInt(1500)), () {
      _controller.repeat(reverse: true);
    });

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(offsetX, offsetY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Text(
            widget.emoji,
            style: const TextStyle(
              fontSize: 36,
            ),
          ),
        ),
      ),
    );
  }
}
