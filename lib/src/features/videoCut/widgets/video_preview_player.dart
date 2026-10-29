import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:video_player/video_player.dart';

import '../presentation/viewmodel/video_cut_viewmodel.dart';

class VideoPreviewPlayer extends ConsumerStatefulWidget {
  const VideoPreviewPlayer({super.key});

  @override
  ConsumerState<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends ConsumerState<VideoPreviewPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && ref.read(videoCutViewModelProvider).isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls(bool isPlaying) {
    setState(() => _showControls = !_showControls);
    if (_showControls && isPlaying) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  String _formatTime(double sec) {
    if (sec.isNaN || sec.isInfinite || sec < 0) sec = 0;
    final d = Duration(milliseconds: (sec * 1000).toInt());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCutViewModelProvider);
    final vm = ref.read(videoCutViewModelProvider.notifier);
    final controller = vm.playerController;
    final isDark = context.isDark;
    final accent = AppTokens.accent(isDark);

    final startSec = state.startSec;
    final endSec = state.endSec > startSec ? state.endSec : (startSec + 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.black,
        height: 230,
        width: double.infinity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleControls(state.isPlaying),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Video Player
              if (controller != null && controller.value.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio > 0
                        ? controller.value.aspectRatio
                        : (16 / 9),
                    child: VideoPlayer(controller),
                  ),
                )
              else
                Center(child: CircularProgressIndicator(color: accent)),

              // 2. Center Play / Pause / Replay Buttons (QA Bug iii Fix: Auto-hide & Tap)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Replay to Start Button
                      InkWell(
                        onTap: () {
                          vm.seekTo(state.startSec);
                          _startHideTimer();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),

                      // Center Play / Pause Button
                      InkWell(
                        onTap: () {
                          vm.togglePlayPause();
                          if (!state.isPlaying) {
                            _startHideTimer();
                          }
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Progress Bar & Timestamps (QA Bug i & ii Fix)
              if (controller != null && controller.value.isInitialized)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            final currentSec =
                                controller.value.position.inMilliseconds /
                                1000.0;
                            return Row(
                              children: [
                                // Start / Current Timestamp
                                Text(
                                  _formatTime(currentSec),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Scrubber Slider
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5.5,
                                      ),
                                      trackHeight: 2.5,
                                      activeTrackColor: accent,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.white,
                                      overlayShape:
                                          SliderComponentShape.noOverlay,
                                    ),
                                    child: Slider(
                                      value: currentSec.clamp(startSec, endSec),
                                      min: startSec,
                                      max: endSec,
                                      onChanged: (val) {
                                        vm.seekTo(val);
                                        _startHideTimer();
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // End / Trimmed Timestamp
                                Text(
                                  _formatTime(endSec),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
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
}
