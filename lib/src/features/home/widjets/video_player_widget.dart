import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final Function(double durationSec) onDurationLoaded;
  // 👉 QA Bug 4 Fix: Trimmed start & end ranges
  final double? startSec;
  final double? endSec;

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    required this.onDurationLoaded,
    this.startSec,
    this.endSec,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInit = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  // Calculate start in milliseconds
  int get _startMs => ((widget.startSec ?? 0.0) * 1000).toInt();

  // Calculate end in milliseconds
  int _endMs(Duration totalDur) {
    if (widget.endSec != null && widget.endSec! > 0) {
      return (widget.endSec! * 1000).toInt().clamp(0, totalDur.inMilliseconds);
    }
    return totalDur.inMilliseconds;
  }

  Future<void> _initPlayer() async {
    try {
      final file = File(widget.videoPath);
      if (!await file.exists()) {
        if (mounted) setState(() => _hasError = true);
        return;
      }

      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();

      if (mounted) {
        setState(() => _isInit = true);
        final durSec = _controller!.value.duration.inMilliseconds / 1000.0;

        // Agar startSec set hai to shuru se hi wahan seek karein
        if (_startMs > 0) {
          await _controller!.seekTo(Duration(milliseconds: _startMs));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onDurationLoaded(durSec);
        });

        _controller!.addListener(_handlePlayback);
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _handlePlayback() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized)
      return;

    final posMs = _controller!.value.position.inMilliseconds;
    final totalDur = _controller!.value.duration;
    final endMs = _endMs(totalDur);

    // 👉 Agar video play hote huwe trimmed end cross kare tou pause karein aur start pe le aaein
    if (_controller!.value.isPlaying && posMs >= endMs) {
      _controller!.pause();
      _controller!.seekTo(Duration(milliseconds: _startMs));
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 👉 Edit screen se wapis aane par agar start/end change ho gaya hai to video ko new start pe le aao
    if (oldWidget.startSec != widget.startSec ||
        oldWidget.endSec != widget.endSec) {
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.pause();
        _controller!.seekTo(Duration(milliseconds: _startMs));
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handlePlayback);
    _controller?.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final controller = _controller;
    final accent = AppTokens.accent(isDark);

    final rawPos = controller?.value.position ?? Duration.zero;
    final totalDur = controller?.value.duration ?? Duration.zero;

    final startMs = _startMs;
    final endMs = _endMs(totalDur);

    // Trimmed Duration calculation (e.g. 5s - 3s = 2s)
    final effectiveDurMs = (endMs - startMs).clamp(0, totalDur.inMilliseconds);
    final effectiveDur = Duration(milliseconds: effectiveDurMs);

    // Relative current position (0s to 2s)
    final relativePosMs = (rawPos.inMilliseconds - startMs).clamp(
      0,
      effectiveDurMs,
    );
    final relativePos = Duration(milliseconds: relativePosMs);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        width: double.infinity,
        color: isDark ? const Color(0xFF141C19) : const Color(0xFF202C26),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video View
            if (_hasError)
              Center(
                child: Text(
                  'Video preview unavailable',
                  style: TextStyle(
                    color: AppTokens.textSecondary(isDark),
                    fontSize: 13,
                  ),
                ),
              )
            else if (_isInit && controller != null)
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

            // Bottom Controls Bar (Figma Match)
            if (_isInit && controller != null)
              Positioned(
                bottom: 8,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Play / Pause Button
                      InkWell(
                        onTap: () {
                          if (controller.value.isPlaying) {
                            controller.pause();
                          } else {
                            // Agar video end par hai tou start se play karein
                            if (rawPos.inMilliseconds >= endMs ||
                                rawPos.inMilliseconds < startMs) {
                              controller
                                  .seekTo(Duration(milliseconds: startMs))
                                  .then((_) => controller.play());
                            } else {
                              controller.play();
                            }
                          }
                        },
                        child: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Scrubber Slider (Relative to Trim)
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            trackHeight: 3.0,
                            activeTrackColor: accent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: relativePosMs.toDouble().clamp(
                              0.0,
                              effectiveDurMs > 0
                                  ? effectiveDurMs.toDouble()
                                  : 1.0,
                            ),
                            max: effectiveDurMs > 0
                                ? effectiveDurMs.toDouble()
                                : 1.0,
                            onChanged: (val) {
                              controller.seekTo(
                                Duration(milliseconds: startMs + val.toInt()),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Time Display (e.g. 00:01 / 00:02)
                      Text(
                        "${_formatTime(relativePos)} / ${_formatTime(effectiveDur)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
