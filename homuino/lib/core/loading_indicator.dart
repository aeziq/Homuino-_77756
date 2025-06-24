import 'package:flutter/material.dart';
/// A customizable circular loading indicator with optional message
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.0,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? theme.primaryColor),
        strokeWidth: strokeWidth,
      ),
    );

    if (message != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
        ],
      );
    }

    return Center(child: indicator);
  }
}

/// Full-screen loading overlay with optional background color
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Widget? customLoader;

  const FullScreenLoader({
    Key? key,
    this.message,
    this.backgroundColor,
    this.customLoader,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.3),
      body: Center(
        child: customLoader ?? LoadingIndicator(
          size: 32,
          strokeWidth: 3.0,
          message: message,
        ),
      ),
    );
  }
}

/// Compact loader designed for buttons
class ButtonLoader extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const ButtonLoader({
    Key? key,
    required this.color,
    this.size = 20,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Widget that shows a loading overlay on top of existing content
class OverlayLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;

  const OverlayLoader({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withOpacity(0.3),
              child: Center(
                child: LoadingIndicator(message: message),
              ),
            ),
          ),
      ],
    );
  }
}