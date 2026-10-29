import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_tokens.dart';
import '../viewmodel/converter_providers.dart';
import '../viewmodel/cut_viewmodel.dart';

class VideoCutScreen extends ConsumerWidget {
  const VideoCutScreen({super.key});

  static String formatTime(double sec) {
    if (sec < 0) sec = 0;
    int totalMs = (sec * 1000).toInt();
    int mins = totalMs ~/ 60000;
    int secs = (totalMs % 60000) ~/ 1000;
    int ms = (totalMs % 1000) ~/ 100;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(mins)}:${twoDigits(secs)}.$ms";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cutViewModelProvider);
    final viewModel = ref.read(cutViewModelProvider.notifier);
    final isDark = context.isDark;
    final accent = AppTokens.accent(isDark);
    final trimmedDuration = (state.endSec - state.startSec).clamp(
      0.0,
      state.totalDurationSec,
    );

    return Scaffold(
      backgroundColor: AppTokens.bg(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // ================= 1. VIDEO PREVIEW =================
            Container(
              height: 240,
              width: double.infinity,
              color: isDark ? const Color(0xFF141C19) : const Color(0xFF202C26),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),

                  if (state.isInitialized && viewModel.controller != null)
                    Center(
                      child: AspectRatio(
                        aspectRatio: viewModel.controller!.value.aspectRatio > 0
                            ? viewModel.controller!.value.aspectRatio
                            : (16 / 9),
                        child: VideoPlayer(viewModel.controller!),
                      ),
                    )
                  else
                    Center(child: CircularProgressIndicator(color: accent)),

                  if (state.isInitialized)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleBtn(
                          isDark: isDark,
                          icon: Icons.first_page_rounded,
                          onTap: () => viewModel.rewindToStart(),
                        ),
                        const SizedBox(width: 28),
                        _buildCircleBtn(
                          isDark: isDark,
                          icon: state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: () => viewModel.togglePlay(),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ================= 2. ACTION BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTokens.text(isDark),
                      size: 26,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    'Cut',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.text(isDark),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: accent, size: 28),
                    onPressed: () {
                      ref
                          .read(converterViewModelProvider.notifier)
                          .setCutRange(state.startSec, state.endSec);
                      context.pop();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ================= 3. TIME PILLS & DURATION =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimePill(
                    isDark: isDark,
                    timeStr: formatTime(state.startSec),
                    onMinus: () {
                      viewModel.updateStart(state.startSec - 0.1);
                      viewModel.seekTo(state.startSec - 0.1);
                    },
                    onPlus: () {
                      viewModel.updateStart(state.startSec + 0.1);
                      viewModel.seekTo(state.startSec + 0.1);
                    },
                  ),

                  Text(
                    formatTime(trimmedDuration),
                    style: TextStyle(
                      color: accent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  _buildTimePill(
                    isDark: isDark,
                    timeStr: formatTime(state.endSec),
                    onMinus: () {
                      viewModel.updateEnd(state.endSec - 0.1);
                      viewModel.seekTo(state.endSec - 0.1);
                    },
                    onPlus: () {
                      viewModel.updateEnd(state.endSec + 0.1);
                      viewModel.seekTo(state.endSec + 0.1);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= 4. BUTTERY SMOOTH TRIMMER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SmoothFilmstripTrimmer(
                isDark: isDark,
                accent: accent,
                state: state,
                viewModel: viewModel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF202C26) : Colors.white).withOpacity(
            0.9,
          ),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppTokens.text(isDark), size: 28),
      ),
    );
  }

  Widget _buildTimePill({
    required bool isDark,
    required String timeStr,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    final accent = AppTokens.accent(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppTokens.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.remove, color: accent, size: 16),
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              color: AppTokens.text(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          InkWell(
            onTap: onPlus,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.add, color: accent, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ISOLATED SMOOTH TRIMMER WIDGET (Zero Lag, RepaintBoundary Protected)
// ============================================================================
class _SmoothFilmstripTrimmer extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final dynamic state;
  final dynamic viewModel;

  const _SmoothFilmstripTrimmer({
    required this.isDark,
    required this.accent,
    required this.state,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const handleWidth = 20.0;
        final usableWidth = totalWidth - handleWidth * 2;

        final leftX = state.totalDurationSec > 0
            ? ((state.startSec / state.totalDurationSec) * usableWidth).clamp(
                0.0,
                usableWidth,
              )
            : 0.0;

        final rightX = state.totalDurationSec > 0
            ? (((state.endSec / state.totalDurationSec) * usableWidth) +
                      handleWidth)
                  .clamp(leftX + handleWidth, totalWidth - handleWidth)
            : totalWidth - handleWidth;

        final selectedWidth = (rightX - leftX + handleWidth).clamp(
          handleWidth * 2,
          totalWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. GPU CACHED THUMBNAIL TRACK (RepaintBoundary eliminates lag!)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: Row(
                        children: List.generate(8, (index) {
                          final hasThumb = index < state.thumbnailPaths.length;
                          return Expanded(
                            child: Container(
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTokens.card(isDark),
                                border: Border.all(
                                  color: AppTokens.border(isDark),
                                  width: 0.5,
                                ),
                              ),
                              child: hasThumb
                                  ? Image.file(
                                      File(state.thumbnailPaths[index]),
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                      cacheWidth: 100, // Memory optimization!
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 20,
                                        color: AppTokens.textSecondary(isDark),
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // 2. Dimmed Overlays
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: leftX,
                    child: Container(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(
                        0.65,
                      ),
                    ),
                  ),
                  Positioned(
                    left: rightX + handleWidth,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(
                        0.65,
                      ),
                    ),
                  ),

                  // 3. Selection Top & Bottom Accent Bars
                  Positioned(
                    left: leftX,
                    width: selectedWidth,
                    top: 0,
                    height: 3,
                    child: Container(color: accent),
                  ),
                  Positioned(
                    left: leftX,
                    width: selectedWidth,
                    bottom: 0,
                    height: 3,
                    child: Container(color: accent),
                  ),

                  // 4. Left Drag Handle
                  Positioned(
                    left: leftX,
                    top: 0,
                    bottom: 0,
                    width: handleWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        if (usableWidth <= 0) return;
                        final newLeft = (leftX + details.delta.dx).clamp(
                          0.0,
                          rightX - 24,
                        );
                        viewModel.updateStart(
                          (newLeft / usableWidth) * state.totalDurationSec,
                        );
                      },
                      onHorizontalDragEnd: (_) =>
                          viewModel.seekTo(state.startSec),
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chevron_left,
                            color: AppTokens.buttonText(isDark),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. Right Drag Handle
                  Positioned(
                    left: rightX,
                    top: 0,
                    bottom: 0,
                    width: handleWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        if (usableWidth <= 0) return;
                        final newRight = (rightX + details.delta.dx).clamp(
                          leftX + 24,
                          totalWidth - handleWidth,
                        );
                        viewModel.updateEnd(
                          ((newRight - handleWidth) / usableWidth) *
                              state.totalDurationSec,
                        );
                      },
                      onHorizontalDragEnd: (_) =>
                          viewModel.seekTo(state.endSec),
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chevron_right,
                            color: AppTokens.buttonText(isDark),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 6. Scrubber Pointer
            if (state.totalDurationSec > 0)
              Padding(
                padding: EdgeInsets.only(
                  left:
                      ((state.currentPosSec / state.totalDurationSec) *
                              (totalWidth - 36))
                          .clamp(0.0, totalWidth - 36),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      VideoCutScreen.formatTime(state.currentPosSec),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.text(isDark),
                      ),
                    ),
                    Icon(Icons.water_drop, color: accent, size: 16),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
