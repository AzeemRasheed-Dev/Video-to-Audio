import 'package:flutter/material.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';

class AudioPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipToStart;
  final VoidCallback onSkipToEnd;
  final VoidCallback onRewind5;
  final VoidCallback onForward5;

  const AudioPlayerControls({
    super.key,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onSkipToStart,
    required this.onSkipToEnd,
    required this.onRewind5,
    required this.onForward5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = AppTokens.accent(isDark);
    final btnText = isDark ? AppTokens.darkBtnText : AppTokens.lightBtnText;
    final iconColor = AppTokens.textSecondary(isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 1. Jump to Start |◀
        IconButton(
          onPressed: onSkipToStart,
          tooltip: 'Jump to start',
          icon: Icon(Icons.skip_previous_rounded, color: iconColor, size: 28),
        ),

        // 2. Rewind 5s ↺ 5
        IconButton(
          onPressed: onRewind5,
          tooltip: 'Rewind 5s',
          icon: Icon(Icons.replay_5_rounded, color: iconColor, size: 28),
        ),

        // 3. Central Accent Play / Pause Button ▶
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: btnText,
              size: 34,
            ),
          ),
        ),

        // 4. Forward 5s ↻ 5
        IconButton(
          onPressed: onForward5,
          tooltip: 'Forward 5s',
          icon: Icon(Icons.forward_5_rounded, color: iconColor, size: 28),
        ),

        // 5. Jump to End ▶|
        IconButton(
          onPressed: onSkipToEnd,
          tooltip: 'Jump to end',
          icon: Icon(Icons.skip_next_rounded, color: iconColor, size: 28),
        ),
      ],
    );
  }
}