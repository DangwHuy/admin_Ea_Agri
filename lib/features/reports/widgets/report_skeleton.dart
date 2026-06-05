import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';

class SkeletonContainer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Default light mode colors, will be updated in didChangeDependencies
    _colorAnimation = ColorTween(
      begin: Colors.grey[200],
      end: Colors.grey[300],
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _colorAnimation = ColorTween(
      begin: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
      end: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300],
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
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class ReportSkeletonCard extends StatelessWidget {
  const ReportSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonContainer(width: 48, height: 48, borderRadius: 12),
              SkeletonContainer(width: 60, height: 20),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonContainer(width: 140, height: 32),
          const SizedBox(height: 8),
          const SkeletonContainer(width: 100, height: 16),
        ],
      ),
    );
  }
}
