import 'package:flutter/material.dart';

class StaggeredFadeSlide extends StatelessWidget {
  const StaggeredFadeSlide({
    super.key,
    required this.child,
    required this.isVisible,
  });

  final Widget child;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0.0, 0.15),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}
