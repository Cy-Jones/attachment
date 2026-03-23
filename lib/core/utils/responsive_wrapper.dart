import 'package:flutter/material.dart';

/// A system-level wrapper that prevents UI elements from stretching
/// uncontrollably on tablets and desktop-sized screens.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500, // Standard max width for mobile-style auth forms
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
}