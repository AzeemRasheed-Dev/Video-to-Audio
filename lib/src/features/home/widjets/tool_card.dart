import 'package:flutter/material.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';


class ToolCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Widget graphic;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.graphic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTokens.card(isDark),
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(color: AppTokens.border(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 01, 02, 03 & Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      color: AppTokens.textSecondary(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppTokens.text(isDark), size: 20),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: AppTokens.text(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTokens.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              graphic,
            ],
          ),
        ),
      ),
    );
  }
}

// --- Figma Graphics ---
class ToolGraphics {
  const ToolGraphics._();

  // 1. Video to Audio Graphic (Reel -> Arrow -> Waveform)
  static Widget videoToAudio(BuildContext context) {
    final accent = AppTokens.accent(context.isDark);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: accent, width: 2),
          ),
          child: Icon(Icons.play_arrow_rounded, color: accent, size: 20),
        ),
        const SizedBox(width: 14),
        Icon(Icons.arrow_forward_rounded, color: AppTokens.textSecondary(context.isDark), size: 18),
        const SizedBox(width: 14),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(20, (i) {
              final heights = [6, 12, 20, 14, 26, 32, 18, 10, 24, 28, 16, 8, 22, 14, 18, 10, 6, 12, 16, 8];
              return Container(
                width: 2.2,
                height: heights[i % heights.length].toDouble(),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 2. Audio Cutter Graphic (Waveform with Trim Handles)
  static Widget audioCutter(BuildContext context) {
    final accent = AppTokens.accent(context.isDark);
    final muted = AppTokens.textSecondary(context.isDark).withOpacity(0.3);

    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(28, (i) {
              final isTrimmed = i >= 8 && i <= 18;
              final heights = [6, 12, 20, 26, 16, 10, 22, 28, 14, 8, 18, 12];
              return Container(
                width: 2.2,
                height: heights[i % heights.length].toDouble(),
                decoration: BoxDecoration(
                  color: isTrimmed ? accent : muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          FractionallySizedBox(
            widthFactor: 0.42,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                border: Border.all(color: accent, width: 1.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Video Cutter Graphic (Filmstrip with Scrubber Dot)
  static Widget videoCutter(BuildContext context) {
    final accent = AppTokens.accent(context.isDark);
    return Column(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
        Container(width: 2, height: 6, color: accent),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Row(
            children: List.generate(8, (i) => Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: i < 7 ? BorderSide(color: accent.withOpacity(0.5)) : BorderSide.none),
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }
}