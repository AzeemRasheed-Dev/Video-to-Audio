import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/converter_providers.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/result_viewmodel.dart';
import 'package:my_app/src/features/home/widjets/native_ad_card.dart';

// 👉 QA Bug 8 & 9: Custom Dialog & Custom Toast
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/custom_toast.dart';

class ConversionResultScreen extends ConsumerStatefulWidget {
  const ConversionResultScreen({super.key});

  @override
  ConsumerState<ConversionResultScreen> createState() =>
      _ConversionResultScreenState();
}

class _ConversionResultScreenState
    extends ConsumerState<ConversionResultScreen> {
  String _formatTime(double sec) {
    if (sec < 0) sec = 0;
    int totalMs = (sec * 1000).toInt();
    int mins = totalMs ~/ 60000;
    int secs = (totalMs % 60000) ~/ 1000;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(mins)}:${twoDigits(secs)}";
  }

  // 👉 QA Bug 7: 2-Step Ringtone Flow with Custom Dialogs
  void _handleSetAsRingtone(BuildContext context, dynamic resultVM) {
    // Step 1: Confirmation Dialog
    CustomDialog.show(
      context,
      title: 'Set as Ringtone?',
      message:
          'Would you like to set this audio as your default phone ringtone?',
      icon: Icons.notifications_active_rounded,
      confirmText: 'Yes',
      cancelText: 'Cancel',
      onConfirm: () {
        // Step 2: Permission Explanation Dialog
        CustomDialog.show(
          context,
          title: 'Permission Required',
          message:
              'To set a custom ringtone, please allow the app to modify system settings.',
          icon: Icons.settings_rounded,
          confirmText: 'Allow Permission',
          cancelText: 'Cancel',
          onConfirm: () async {
            final ok = await resultVM.setRingtone();
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = AppTokens.accent(isDark);
    final convState = ref.watch(converterViewModelProvider);
    final resultState = ref.watch(resultViewModelProvider);
    final resultVM = ref.read(resultViewModelProvider.notifier);

    // Dynamic Format & Bitrate
    final formatStr = (convState.selectedFormat.isNotEmpty)
        ? convState.selectedFormat.toUpperCase()
        : 'AAC';

    final bitrateStr = convState.selectedBitrate.isNotEmpty
        ? (convState.selectedBitrate.toLowerCase().contains('k')
              ? '${convState.selectedBitrate.toLowerCase().replaceAll('k', '')} kbps'
              : '${convState.selectedBitrate} kbps')
        : '128 kbps';

    final baseVideoName = convState.videoName != null
        ? (convState.videoName!.contains('.')
              ? convState.videoName!.substring(
                  0,
                  convState.videoName!.lastIndexOf('.'),
                )
              : convState.videoName!)
        : 'Studio session';

    final audioName =
        '$baseVideoName.${convState.selectedFormat.toLowerCase()}';

    return Scaffold(
      backgroundColor: AppTokens.bg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 44,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTokens.text(isDark),
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Result',
          style: TextStyle(
            color: AppTokens.text(isDark),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        // 👉 QA Bug 10 Fix: 3 vertical dots icon removed from actions
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ================= 1. COMPACT CHECKMARK =================
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 1.6),
                ),
                child: Icon(Icons.check_rounded, color: accent, size: 24),
              ),
              const SizedBox(height: 10),

              Text(
                'Your files are ready',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppTokens.text(isDark),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Saved and ready to use.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTokens.textSecondary(isDark),
                ),
              ),

              const SizedBox(height: 20),

              // ================= 2. CONVERTED AUDIO CARD (QA Bug 5 & 6 Fix) =================
              // (Tabs aur Original Video remove kar diye hain, sirf ye converted audio card display hoga)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTokens.border(isDark),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sleek Waveform Graphic
                    SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(32, (i) {
                          final pattern = [
                            6,
                            12,
                            20,
                            26,
                            34,
                            18,
                            8,
                            22,
                            36,
                            28,
                            14,
                            8,
                            16,
                            30,
                            36,
                            22,
                            10,
                            18,
                            30,
                            14,
                            8,
                            18,
                            24,
                            12,
                          ];
                          final h = pattern[i % pattern.length].toDouble();
                          return Container(
                            width: 2.2,
                            height: h,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Audio Title
                    Text(
                      audioName,
                      style: TextStyle(
                        color: AppTokens.text(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Metadata
                    Text(
                      '$formatStr • $bitrateStr',
                      style: TextStyle(
                        color: AppTokens.textSecondary(isDark),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Player Controls
                    Row(
                      children: [
                        // Play / Pause Circle
                        InkWell(
                          onTap: () => resultVM.togglePlay(),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              resultState.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppTokens.buttonText(isDark),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Scrubber Slider
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5.0,
                              ),
                              trackHeight: 2.5,
                              activeTrackColor: accent,
                              inactiveTrackColor: AppTokens.border(isDark),
                              thumbColor: accent,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: resultState.currentPosSec.clamp(
                                0.0,
                                resultState.totalDurSec > 0
                                    ? resultState.totalDurSec
                                    : 1.0,
                              ),
                              max: resultState.totalDurSec > 0
                                  ? resultState.totalDurSec
                                  : 1.0,
                              onChanged: (val) => resultVM.seekTo(val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Time
                        Text(
                          "${_formatTime(resultState.currentPosSec)} / ${_formatTime(resultState.totalDurSec)}",
                          style: TextStyle(
                            color: AppTokens.textSecondary(isDark),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= 3. AUDIO ACTIONS =================
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AUDIO ACTIONS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: AppTokens.textSecondary(isDark),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.ios_share_rounded,
                      label: 'Share',
                      isDark: isDark,
                      onTap: () => resultVM.shareAudio(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.download_rounded,
                      label: 'Download',
                      isDark: isDark,
                      onTap: () async {
                        final path = await resultVM.saveToDownloads(
                          convState.videoName,
                          convState.selectedFormat,
                        );
                        if (context.mounted) {
                          // 👉 QA Bug 9: Custom Toast
                          if (path != null) {
                            CustomToast.show(
                              'Saved to Downloads!',
                              context: context,
                              icon: Icons.check_circle_rounded,
                            );
                          } else {
                            CustomToast.show(
                              'Save failed!',
                              context: context,
                              icon: Icons.error_outline_rounded,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.notifications_none_rounded,
                      label: 'Set as',
                      isDark: isDark,
                      // 👉 QA Bug 7: Trigger 2-step permission flow
                      onTap: () => _handleSetAsRingtone(context, resultVM),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Actions apply to the extracted audio.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTokens.textSecondary(
                    isDark,
                  ).withValues(alpha: 0.75),
                ),
              ),

              const SizedBox(height: 16),

              // ================= 4. NATIVE AD CARD =================
              const NativeAdCard(),

              const SizedBox(height: 16),

              // ================= 5. BACK TO HOME BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppTokens.buttonText(isDark),
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
                      color: AppTokens.buttonText(isDark),
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
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
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
