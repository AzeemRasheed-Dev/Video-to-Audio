import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class CustomDialog {
  CustomDialog._();

  /// Displays a customized modal dialog styled to Emerald Green design system.
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    IconData icon = Icons.info_outline_rounded,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool showCancelButton = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        return _CustomDialogWidget(
          title: title,
          message: message,
          icon: icon,
          confirmText: confirmText,
          cancelText: cancelText,
          barrierDismissible: barrierDismissible,
          showCancelButton: showCancelButton,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
            onCancel?.call();
          },
        );
      },
    );
  }
}

class _CustomDialogWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final String confirmText;
  final String cancelText;
  final bool barrierDismissible;
  final bool showCancelButton;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _CustomDialogWidget({
    required this.title,
    this.message,
    required this.icon,
    required this.confirmText,
    required this.cancelText,
    required this.barrierDismissible,
    required this.showCancelButton,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = AppTokens.card(isDark);
    final borderCol = AppTokens.border(isDark);
    final textCol = AppTokens.text(isDark);
    final textMuted = AppTokens.textSecondary(isDark);
    final accent = AppTokens.accent(isDark);

    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 48.0, 20.0, 20.0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: accent.withValues(alpha: 0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Floating Icon Badge on top border
              Positioned(
                top: -80.0,
                child: Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accent, const Color(0xFF3B9B7E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 30.0),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8.0),

                  // Title Text
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                      height: 1.25,
                    ),
                  ),

                  if (message != null) ...[
                    const SizedBox(height: 10.0),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24.0),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Secondary Cancel Button
                      if (showCancelButton) ...[
                        Expanded(
                          child: InkWell(
                            onTap: onCancel,
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1B2421)
                                    : const Color(0xFFE9EFEA),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: borderCol,
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                cancelText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: textCol,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                      ],

                      // Primary Confirm Button
                      Expanded(
                        child: InkWell(
                          onTap: onConfirm,
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              confirmText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
