import 'package:flutter/material.dart';

class AppSliverBox extends StatelessWidget {
  const AppSliverBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(child: child),
    );
  }
}

class AppSliverGap extends StatelessWidget {
  const AppSliverGap(this.height, {super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: SizedBox(height: height));
  }
}
