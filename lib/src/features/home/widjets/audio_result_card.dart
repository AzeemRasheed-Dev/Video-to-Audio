import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/converter_providers.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/result_viewmodel.dart';


class AudioResultCard extends ConsumerWidget {
  const AudioResultCard({super.key});

  String _formatTime(double sec) {
    int totalMs = (sec * 1000).toInt();
    int mins = totalMs ~/ 60000;
    int secs = (totalMs % 60000) ~/ 1000;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(mins)}:${twoDigits(secs)}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convState = ref.watch(converterViewModelProvider);
    final resultState = ref.watch(resultViewModelProvider);
    final resultVM = ref.read(resultViewModelProvider.notifier);
    final isDark = context.isDark;
    final accent = AppTokens.accent(isDark);

    final displayName = convState.videoName != null
        ? '${convState.videoName!.split('.').first}.${convState.selectedFormat}'
        : 'Audio File';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTokens.card(isDark),
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppTokens.border(isDark), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sound Waveform Graphic (Figma Match)
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(34, (i) {
                final pattern = [8, 14, 22, 16, 28, 38, 44, 32, 20, 36, 42, 26, 18, 28, 36, 14, 10, 24, 30, 18, 12];
                final h = pattern[i % pattern.length].toDouble();
                return Container(
                  width: 2.4,
                  height: h,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Audio Title
          Text(
            displayName,
            style: TextStyle(
              color: AppTokens.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // 3. Metadata (Format • Bitrate • Size)
          Text(
            '${convState.selectedFormat.toUpperCase()} • ${convState.selectedBitrate} kbps',
            style: TextStyle(
              color: AppTokens.textSecondary(isDark),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 14),

          // 4. Player Controls (Play button + Scrubber Slider + Time)
          Row(
            children: [
              // Circular Accent Play/Pause Button
              InkWell(
                onTap: () => resultVM.togglePlay(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resultState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppTokens.buttonText(isDark),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 2.8,
                    activeTrackColor: accent,
                    inactiveTrackColor: AppTokens.border(isDark),
                    thumbColor: accent,
                  ),
                  child: Slider(
                    value: resultState.currentPosSec.clamp(
                      0.0,
                      resultState.totalDurSec > 0 ? resultState.totalDurSec : 1.0,
                    ),
                    max: resultState.totalDurSec > 0 ? resultState.totalDurSec : 1.0,
                    onChanged: (val) => resultVM.seekTo(val),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Time Indicator (00:00 / 03:15)
              Text(
                "${_formatTime(resultState.currentPosSec)} / ${_formatTime(resultState.totalDurSec)}",
                style: TextStyle(
                  color: AppTokens.textSecondary(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}