import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import '../../presentation/viewmodel/video_cut_viewmodel.dart';

class VideoRangeTrimmer extends ConsumerWidget {
  const VideoRangeTrimmer({super.key});

  String _formatMinutes(double sec) {
    if (sec < 0) sec = 0;
    final total = sec.toInt();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCutViewModelProvider);
    final vm = ref.read(videoCutViewModelProvider.notifier);
    final isDark = context.isDark;

    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final accent = AppTokens.accent(isDark);
    final totalSec = state.totalDurationSec > 0 ? state.totalDurationSec : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Title & Duration
        Text(
          state.videoName ?? 'Selected video.mp4',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${_formatMinutes(totalSec)} total',
          style: TextStyle(
            color: textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),

        // SELECT RANGE Label
        Text(
          'SELECT RANGE',
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        // Timeline Strip
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final startX = (state.startSec / totalSec) * totalWidth;
            final endX = (state.endSec / totalSec) * totalWidth;
            final currentX = (state.currentPosSec / totalSec) * totalWidth;

            // Handle touch width (44px touch area for effortless grabbing)
            const handleTouchWidth = 44.0;
            const handleVisualWidth = 18.0;

            return SizedBox(
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 👉 QA Bug iv Fix: Real Video Thumbnails (Paharon ki images removed)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: List.generate(8, (i) {
                          final hasThumbnails = state.thumbnails != null &&
                              state.thumbnails!.length > i &&
                              File(state.thumbnails![i]).existsSync();

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0.5),
                              color: isDark
                                  ? const Color(0xFF1E2824)
                                  : const Color(0xFFC8D4CF),
                              child: hasThumbnails
                                  ? Image.file(
                                      File(state.thumbnails![i]),
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.movie_creation_outlined,
                                        color: isDark ? Colors.white24 : Colors.black26,
                                        size: 20,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Dimmed Out-of-Range Overlays
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: startX.clamp(0.0, totalWidth),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: endX.clamp(0.0, totalWidth),
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                    ),
                  ),

                  // Active Range Top & Bottom Borders
                  Positioned(
                    left: startX.clamp(0.0, totalWidth),
                    width: (endX - startX).clamp(0.0, totalWidth),
                    top: 0,
                    child: Container(height: 3, color: accent),
                  ),
                  Positioned(
                    left: startX.clamp(0.0, totalWidth),
                    width: (endX - startX).clamp(0.0, totalWidth),
                    bottom: 0,
                    child: Container(height: 3, color: accent),
                  ),

                  // Needle Playhead with Dot
                  Positioned(
                    left: (currentX - 4).clamp(0.0, totalWidth - 8),
                    top: -6,
                    bottom: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Container(width: 2, color: accent)),
                      ],
                    ),
                  ),

                  // 👉 QA Bug v Fix: LEFT Handle with 44px Touch Target
                  Positioned(
                    left: (startX - (handleTouchWidth / 2)).clamp(-handleTouchWidth / 2, totalWidth - handleTouchWidth / 2),
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) =>
                          vm.adjustStart((d.delta.dx / totalWidth) * totalSec),
                      child: Container(
                        width: handleTouchWidth,
                        alignment: Alignment.center,
                        child: Container(
                          width: handleVisualWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 👉 QA Bug v Fix: RIGHT Handle with 44px Touch Target
                  Positioned(
                    left: (endX - (handleTouchWidth / 2)).clamp(-handleTouchWidth / 2, totalWidth - handleTouchWidth / 2),
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) =>
                          vm.adjustEnd((d.delta.dx / totalWidth) * totalSec),
                      child: Container(
                        width: handleTouchWidth,
                        alignment: Alignment.center,
                        child: Container(
                          width: handleVisualWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // Timeline Step Markers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatMinutes(0), style: TextStyle(color: textSecondary, fontSize: 11)),
            Text(_formatMinutes(totalSec * 0.33), style: TextStyle(color: textSecondary, fontSize: 11)),
            Text(_formatMinutes(totalSec * 0.66), style: TextStyle(color: textSecondary, fontSize: 11)),
            Text(_formatMinutes(totalSec), style: TextStyle(color: textSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}