import 'package:flutter/material.dart';

/// Global navigator key — GoRouter ya MaterialApp.router me lagayein
final GlobalKey<NavigatorState> customToastNavigatorKey =
    GlobalKey<NavigatorState>();

class CustomToast {
  CustomToast._();

  static OverlayEntry? _currentEntry;

  /// Shows an animated Emerald Green toast pill overlay.
  static void show(
    String message, {
    BuildContext? context,
    bool showIcon = true,
    IconData icon = Icons.check_circle_rounded,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlayState = context != null
        ? Overlay.maybeOf(context)
        : customToastNavigatorKey.currentState?.overlay;

    if (overlayState == null) return;

    try {
      if (_currentEntry != null && _currentEntry!.mounted) {
        _currentEntry!.remove();
      }
    } catch (_) {}
    _currentEntry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        showIcon: showIcon,
        icon: icon,
        duration: duration,
        onDismissed: () {
          try {
            if (entry.mounted) {
              entry.remove();
            }
          } catch (_) {}
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool showIcon;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.showIcon,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;
    final effectiveBottom = keyboardHeight > 0
        ? keyboardHeight + 20.0
        : bottomPadding + 65.0;

    const accent = Color(0xFF266653); // Emerald Green
    const bgColor = Color(0xFF141C19); // Dark Surface

    return Positioned(
      left: 20.0,
      right: 20.0,
      bottom: effectiveBottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showIcon) ...[
                        Icon(
                          widget.icon,
                          size: 18,
                          color: const Color(0xFF388E3C),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
