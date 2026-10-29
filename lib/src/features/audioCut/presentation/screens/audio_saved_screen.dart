import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/core/widgets/custom_dialog.dart';
import 'package:my_app/src/core/widgets/custom_toast.dart';
import 'package:my_app/src/features/audioCut/presentation/viewmodel/convert_dialog_viewmodel.dart';
import 'package:my_app/src/features/home/widjets/native_ad_card.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../viewmodel/audio_saved_viewmodel.dart';

class AudioSavedScreen extends ConsumerStatefulWidget {
  final String audioPath;
  const AudioSavedScreen({super.key, required this.audioPath});

  @override
  ConsumerState<AudioSavedScreen> createState() => _AudioSavedScreenState();
}

class _AudioSavedScreenState extends ConsumerState<AudioSavedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(audioSavedViewModelProvider.notifier)
          .initAudio(widget.audioPath);
    });
  }

  String _formatTime(double sec) {
    if (sec < 0) sec = 0;
    final int totalSec = sec.toInt();
    final int mins = totalSec ~/ 60;
    final int secs = totalSec % 60;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(mins)}:${twoDigits(secs)}";
  }

  String _formatBitrate(String rawBitrate) {
    if (rawBitrate.isEmpty) return '192 kbps';
    if (rawBitrate.toLowerCase().contains('copy')) {
      final match = RegExp(
        r'(\d+)\s*kb/?s?',
        caseSensitive: false,
      ).firstMatch(rawBitrate);
      if (match != null) {
        return '${match.group(1)} kbps';
      }
      return 'Original';
    }
    return rawBitrate
        .replaceAll(RegExp(r'\(.*?\)', caseSensitive: false), '')
        .trim();
  }

  // 👉 QA Bug 7 & 8: 2-Step Ringtone Dialog Flow
  void _handleSetAsRingtone(BuildContext context, String filePath) {
    CustomDialog.show(
      context,
      title: 'Set as Ringtone?',
      message:
          'Would you like to set this audio as your default phone ringtone?',
      icon: Icons.notifications_active_rounded,
      confirmText: 'Yes',
      cancelText: 'Cancel',
      onConfirm: () {
        CustomDialog.show(
          context,
          title: 'Permission Required',
          message:
              'To set a custom ringtone, please allow the app to modify system settings.',
          icon: Icons.settings_rounded,
          confirmText: 'Allow Permission',
          cancelText: 'Cancel',
          onConfirm: () async {
            try {
              final file = File(filePath);
              if (await file.exists()) {
                final ok = await RingtoneSet.setRingtoneFromFile(file);
                if (context.mounted) {
                  if (ok) {
                    CustomToast.show(
                      'Ringtone set successfully!',
                      context: context,
                      icon: Icons.check_circle_rounded,
                    );
                  } else {
                    CustomToast.show(
                      'Permission denied or failed to set ringtone.',
                      context: context,
                      icon: Icons.error_outline_rounded,
                    );
                  }
                }
              }
            } catch (e) {
              if (context.mounted) {
                CustomToast.show(
                  'Failed to set ringtone',
                  context: context,
                  icon: Icons.error_outline_rounded,
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioSavedViewModelProvider);
    final vm = ref.read(audioSavedViewModelProvider.notifier);
    final dialogState = ref.watch(convertDialogViewModelProvider);

    final isDark = context.isDark;
    final bg = AppTokens.bg(isDark);
    final cardBg = AppTokens.card(isDark);
    final accent = AppTokens.accent(isDark);
    final btnText = isDark ? AppTokens.darkBtnText : AppTokens.lightBtnText;
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final border = AppTokens.border(isDark);

    final ext = state.audioPath.contains('.')
        ? state.audioPath.split('.').last.toUpperCase()
        : 'AAC';

    final bitrate = _formatBitrate(dialogState.selectedBitrate);

    return Scaffold(
      backgroundColor: bg,
      // ================= 1. APPBAR =================
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Result',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        // 👉 QA Fix: 3 vertical dots removed
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ================= 2. SUCCESS CHECKMARK HEADER =================
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 1.8),
                ),
                child: Center(
                  child: Icon(Icons.check, color: accent, size: 24),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Your files are ready',
                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Saved and ready to use.',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 18),

              // ================= 3. MAIN CONVERTED AUDIO CARD (Tabs & Original removed) =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWaveformGraphic(accent),
                    const SizedBox(height: 14),

                    // File Name
                    Text(
                      state.fileName.isNotEmpty
                          ? state.fileName
                          : 'audioOutput.$ext',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Dynamic Format & Bitrate Subtitle
                    Text(
                      '$ext • $bitrate',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Player Scrubber Row
                    Row(
                      children: [
                        // Circular Play Button
                        GestureDetector(
                          onTap: vm.togglePlayPause,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: btnText,
                              size: 21,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Scrubber Slider
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.5,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 4.5,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10.0,
                              ),
                              activeTrackColor: accent,
                              inactiveTrackColor: border,
                              thumbColor: accent,
                            ),
                            child: Slider(
                              value: state.currentPosSec.clamp(
                                0.0,
                                state.totalDurationSec > 0
                                    ? state.totalDurationSec
                                    : 1.0,
                              ),
                              max: state.totalDurationSec > 0
                                  ? state.totalDurationSec
                                  : 1.0,
                              onChanged: (val) => vm.seekTo(val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Time Text
                        Text(
                          '${_formatTime(state.currentPosSec)} / ${_formatTime(state.totalDurationSec)}',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 10.5,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ================= 4. AUDIO ACTIONS (ALL 3 OPTIONS KEPT) =================
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AUDIO ACTIONS',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // 1. Share
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      isDark: isDark,
                      onTap: () {
                        if (state.audioPath.isNotEmpty) {
                          Share.shareXFiles([
                            XFile(state.audioPath),
                          ], text: 'My Cut Audio');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. Download
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.download_rounded,
                      label: 'Download',
                      isDark: isDark,
                      onTap: () async {
                        await vm.downloadToDevice();
                        if (context.mounted) {
                          CustomToast.show(
                            state.message ?? 'Saved to Downloads!',
                            context: context,
                            icon: Icons.check_circle_rounded,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 3. Set as (Ringtone Flow)
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.notifications_none_rounded,
                      label: 'Set as',
                      isDark: isDark,
                      onTap: () =>
                          _handleSetAsRingtone(context, state.audioPath),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Actions apply to the trimmed audio file.',
                  style: TextStyle(color: textSecondary, fontSize: 10),
                ),
              ),

              const SizedBox(height: 16),

              // ================= 5. NATIVE AD CARD =================
              const NativeAdCard(),

              const SizedBox(height: 16),

              // ================= 6. BACK TO HOME BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: btnText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Back to home',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: btnText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformGraphic(Color color) {
    const heights = [
      8.0,
      14.0,
      22.0,
      36.0,
      18.0,
      30.0,
      22.0,
      14.0,
      26.0,
      34.0,
      18.0,
      12.0,
      28.0,
      38.0,
      20.0,
      15.0,
      26.0,
      32.0,
      16.0,
      10.0,
      22.0,
      30.0,
      36.0,
      18.0,
      14.0,
      26.0,
      20.0,
      12.0,
      18.0,
      8.0,
      14.0,
      22.0,
      32.0,
      18.0,
      24.0,
      16.0,
      10.0,
      20.0,
      14.0,
      8.0,
    ];

    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: heights
            .map(
              (h) => Container(
                width: 2.2,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 1.6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTokens.text(isDark), size: 22),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.border(isDark), width: 1.0),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: AppTokens.text(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
