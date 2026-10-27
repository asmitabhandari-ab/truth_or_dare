import 'package:flutter/material.dart';

class AppPalette {
  static const ink = Color(0xFF0A0B1B);
  static const surface = Color(0xFF1A1C37);
  static const surfaceLight = Color(0xFF282B4C);
  static const pink = Color(0xFFFF4F7D);
  static const cyan = Color(0xFF65E7FF);
  static const purple = Color(0xFF9B7BFF);
  static const green = Color(0xFF75E6B1);
  static const muted = Color(0xFFB8BAD2);
}

class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101229), AppPalette.ink, Color(0xFF210F2B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -60,
            child: _Glow(color: AppPalette.pink.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: _Glow(color: AppPalette.cyan.withValues(alpha: 0.11)),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 260,
        width: 260,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showBackButton = true,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!),
                actions: actions,
                automaticallyImplyLeading: showBackButton,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
        body: SafeArea(
          top: title == null, 
          bottom: false,
          child: child,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppPalette.pink,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: content) : content;
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppPalette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: child,
    );
  }
}
