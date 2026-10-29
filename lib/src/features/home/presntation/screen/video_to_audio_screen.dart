import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/converter_providers.dart';
import 'package:my_app/src/features/home/widjets/format_bitrate_widget.dart';
import 'package:my_app/src/features/home/widjets/native_ad_card.dart';
import 'package:my_app/src/features/home/widjets/video_player_widget.dart';

import '../../../../core/theme/app_tokens.dart';

class VideoToAudioScreen extends ConsumerWidget {
  const VideoToAudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(converterViewModelProvider);
    final viewModel = ref.read(converterViewModelProvider.notifier);
    final isDark = context.isDark;

    // 👉 QA Bug 4 Fix: Calculate effective trimmed duration (e.g. 5s - 3s = 2s)
    final hasCut = state.cutEndSec > state.cutStartSec && state.cutEndSec > 0;
    final effectiveDuration = hasCut
        ? (state.cutEndSec - state.cutStartSec)
        : state.cutEndSec;

    // 👉 QA Bug 3 Fix: PopScope ensures state resets whether user presses AppBar arrow or phone gesture/hardware back
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          viewModel.reset();
        }
      },
      child: Scaffold(
        backgroundColor: AppTokens.bg(isDark),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTokens.text(isDark)),
            onPressed: () {
              viewModel.reset();
              context.pop();
            },
          ),
          title: Text(
            'Video to Audio',
            style: TextStyle(
              color: AppTokens.text(isDark),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= 1. SOURCE FILE HEADER =================
                      Text(
                        'SOURCE FILE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTokens.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ================= 2. VIDEO PLAYER PREVIEW =================
                      if (state.videoPath != null)
                        VideoPlayerWidget(
                          videoPath: state.videoPath!,
                          // 👉 QA Bug 4 Fix: Trim ranges preview player ko pass ki
                          startSec: state.cutStartSec,
                          endSec: state.cutEndSec,
                          onDurationLoaded: (dur) =>
                              viewModel.setVideoDuration(dur),
                        )
                      else
                        _buildPlaceholderPreview(isDark),

                      const SizedBox(height: 12),

                      // Video Name & Trimmed Duration
                      Text(
                        state.videoName ?? 'Selected video.mp4',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.text(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // 👉 QA Bug 4 Fix: Showing trimmed duration (e.g. 00:02 • Video)
                      Text(
                        '${effectiveDuration > 0 ? _formatDuration(effectiveDuration) : "Ready"} • Video',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTokens.textSecondary(isDark),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= 3. SELECTED RANGE CARD =================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.card(isDark),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTokens.border(isDark)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: AppTokens.accent(isDark),
                              size: 24,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected range',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTokens.textSecondary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.cutEndSec > 0
                                        ? '${_formatTimestamp(state.cutStartSec)} — ${_formatTimestamp(state.cutEndSec)}'
                                        : '00:00.0 — Full Video',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTokens.text(isDark),
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.videoCut),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppTokens.accent(isDark),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ================= 4. EXPORT SETTINGS =================
                      Text(
                        'EXPORT SETTINGS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTokens.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 10),

                      FormatBitrateWidget(
                        selectedFormat: state.selectedFormat,
                        selectedBitrate: state.selectedBitrate,
                        onFormatChanged: (fmt) => viewModel.setFormat(fmt),
                        onBitrateChanged: (br) => viewModel.setBitrate(br),
                      ),

                      const SizedBox(height: 22),

                      // ================= 5. NATIVE SPONSOR AD =================
                      const NativeAdCard(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ================= 6. BOTTOM CONVERT / EXTRACTING SECTION =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: state.isConverting
                    ? _buildExtractingProgress(isDark)
                    : SizedBox(
                        width: double.infinity,
                        height: AppTokens.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await viewModel.convertVideo();
                            if (context.mounted && success) {
                              // Result screen par navigate karein aur wapis aane ka wait karein:
                              await context.push(AppRoutes.conversionResult);
                              // 👉 QA Bug 12 Fix: Result screen se wapis aane par loading bar hat jayegi:
                              viewModel.resetConversionStatus();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTokens.accent(isDark),
                            foregroundColor: AppTokens.buttonText(isDark),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Convert to audio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.buttonText(isDark),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Extracting Audio Progress Bar ---
  Widget _buildExtractingProgress(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Extracting audio...',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTokens.text(isDark),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your audio is being prepared.',
          style: TextStyle(
            fontSize: 12,
            color: AppTokens.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 6,
            color: AppTokens.accent(isDark),
            backgroundColor: AppTokens.border(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderPreview(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTokens.card(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.videocam_rounded,
          color: AppTokens.accent(isDark),
          size: 48,
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String _formatTimestamp(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = ((seconds - seconds.truncate()) * 10).toInt();
    return '$min:$sec.$ms';
  }
}
