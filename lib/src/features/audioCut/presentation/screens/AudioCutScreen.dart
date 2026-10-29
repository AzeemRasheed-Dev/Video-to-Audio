import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/features/audioCut/presentation/viewmodel/convert_dialog_viewmodel.dart';
import 'package:my_app/src/features/audioCut/widjets/convert_audio_dialog.dart';

import '../../widjets/audio_player_controls.dart';
import '../../widjets/audio_waveform_cutter.dart';
import '../viewmodel/AudioCutViewModel.dart';

class AudioCutScreen extends ConsumerWidget {
  const AudioCutScreen({super.key});

  String _formatTime(double sec) {
    if (sec < 0) sec = 0;
    final int totalSec = sec.toInt();
    final int mins = totalSec ~/ 60;
    final int secs = totalSec % 60;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(mins)}:${twoDigits(secs)}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioCutViewModelProvider);
    final vm = ref.read(audioCutViewModelProvider.notifier);
    final isDark = context.isDark;

    final bg = AppTokens.bg(isDark);
    final cardBg = AppTokens.card(isDark);
    final accent = AppTokens.accent(isDark);
    final btnText = AppTokens.btnText(isDark);
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final border = AppTokens.border(isDark);

    // 1. Loading State
    if (!state.isInitialized) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              vm.pause();
              context.pop();
            },
          ),
          title: Text(
            'Audio Cutter',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Center(
          child: state.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFE5214E),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : CircularProgressIndicator(color: accent),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) vm.pause();
      },
      child: Scaffold(
        backgroundColor: bg,

        // ================= 1. APPBAR WITH SAVE BUTTON =================
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () {
              vm.pause();
              context.pop();
            },
          ),
          title: Text(
            'Audio Cutter',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                  onTap: () {
                    final audioCutState = ref.read(audioCutViewModelProvider);
                    if (audioCutState.audioName != null) {
                      ref
                          .read(convertDialogViewModelProvider.notifier)
                          .initDialog(audioCutState.audioName!);
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const ConvertAudioDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        color: btnText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ================= 2. BODY =================
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Source Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.audiotrack_rounded,
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.audioName ?? 'Audio File',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatTime(state.totalDurationSec)} • Audio',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 👉 Waveform Cutter Area (Handles + Time Pills)
                AudioWaveformCutter(
                  totalDuration: state.totalDurationSec,
                  startSec: state.startSec,
                  endSec: state.endSec,
                  currentPosSec: state.currentPosSec,
                  onStartChanged: vm.updateStartSec,
                  onEndChanged: vm.updateEndSec,
                  onSeek: vm.seekTo,
                  onAdjustStart: vm.adjustStart,
                  onAdjustEnd: vm.adjustEnd,
                ),

                const SizedBox(height: 24),

                // 👉 5-Button Player Controls (|◀, ↺5, Play, ↻5, ▶|)
                AudioPlayerControls(
                  isPlaying: state.isPlaying,
                  onTogglePlay: vm.togglePlay,
                  onSkipToStart: vm.skipToStart,
                  onSkipToEnd: vm.skipToEnd,
                  onRewind5: () => vm.seekBy(-5),
                  onForward5: () => vm.seekBy(5),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}