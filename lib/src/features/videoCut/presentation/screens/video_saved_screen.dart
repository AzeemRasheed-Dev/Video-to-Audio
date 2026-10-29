import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/core/widgets/custom_toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../viewmodel/video_saved_viewmodel.dart';

class VideoSavedScreen extends ConsumerStatefulWidget {
  final String videoPath;
  const VideoSavedScreen({super.key, required this.videoPath});

  @override
  ConsumerState<VideoSavedScreen> createState() => _VideoSavedScreenState();
}

class _VideoSavedScreenState extends ConsumerState<VideoSavedScreen> {
  VideoPlayerController? _playerController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoSavedViewModelProvider.notifier)
          .initVideo(widget.videoPath);
    });
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    try {
      final file = File(widget.videoPath);
      if (await file.exists()) {
        _playerController = VideoPlayerController.file(file);
        await _playerController!.initialize();
        if (mounted) {
          setState(() => _isInit = true);
          _playerController!.addListener(() {
            if (mounted) setState(() {});
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$m:$s";
  }

  // 👉 Pencil Icon par Rename Dialog
  void _showRenameDialog(
    BuildContext context,
    String currentName,
    VideoSavedViewModel vm,
  ) {
    final isDark = context.isDark;
    final cardBg = AppTokens.card(isDark);
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final accent = AppTokens.accent(isDark);
    final border = AppTokens.border(isDark);

    final baseName = currentName.contains('.')
        ? currentName.substring(0, currentName.lastIndexOf('.'))
        : currentName;

    final controller = TextEditingController(text: baseName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: accent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Rename Video',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await vm.renameFile(newName);
                if (context.mounted) {
                  CustomToast.show(
                    success
                        ? 'File renamed to $newName'
                        : 'Failed to rename file',
                    context: context,
                    icon: success
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Rename',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoSavedViewModelProvider);
    final vm = ref.read(videoSavedViewModelProvider.notifier);
    final isDark = context.isDark;

    final bg = AppTokens.bg(isDark);
    final cardBg = AppTokens.card(isDark);
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final accent = AppTokens.accent(isDark);

    final controller = _playerController;
    final pos = controller?.value.position ?? Duration.zero;
    final dur = controller?.value.duration ?? Duration.zero;

    return Scaffold(
      backgroundColor: bg,
      // ================= 1. APPBAR =================
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Result',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // 👉 QA Fix: 3 vertical dots removed
      ),

      // ================= 2. BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 6),

            // 👉 Success Circular Checkmark
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 2),
              ),
              child: Center(
                child: Icon(Icons.check_rounded, color: accent, size: 30),
              ),
            ),
            const SizedBox(height: 12),

            // 👉 "Your files are ready" Title & Subtitle
            Text(
              'Your files are ready',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Saved and ready to use.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // ================= 3. INLINE VIDEO PLAYER CARD (QA Bug vi Fix) =================
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTokens.border(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video View with Player Controls
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      height: 210,
                      width: double.infinity,
                      color: Colors.black,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isInit && controller != null)
                            Center(
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio > 0
                                    ? controller.value.aspectRatio
                                    : (16 / 9),
                                child: VideoPlayer(controller),
                              ),
                            )
                          else
                            Center(
                              child: CircularProgressIndicator(color: accent),
                            ),

                          // Play / Pause Tap Overlay
                          if (_isInit && controller != null)
                            GestureDetector(
                              onTap: () {
                                controller.value.isPlaying
                                    ? controller.pause()
                                    : controller.play();
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: controller.value.isPlaying
                                        ? 0.0
                                        : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white38,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Bottom Mini Scrubber
                          if (_isInit && controller != null)
                            Positioned(
                              bottom: 6,
                              left: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatTime(pos),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                enabledThumbRadius: 4,
                                              ),
                                          trackHeight: 2.0,
                                          activeTrackColor: accent,
                                          inactiveTrackColor: Colors.white24,
                                          thumbColor: Colors.white,
                                        ),
                                        child: Slider(
                                          value: pos.inMilliseconds
                                              .toDouble()
                                              .clamp(
                                                0.0,
                                                dur.inMilliseconds > 0
                                                    ? dur.inMilliseconds
                                                          .toDouble()
                                                    : 1.0,
                                              ),
                                          max: dur.inMilliseconds > 0
                                              ? dur.inMilliseconds.toDouble()
                                              : 1.0,
                                          onChanged: (val) {
                                            controller.seekTo(
                                              Duration(
                                                milliseconds: val.toInt(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatTime(dur),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // File Info Bar below player
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                _showRenameDialog(context, state.fileName, vm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.fileName.isNotEmpty
                                            ? state.fileName
                                            : 'video_cut.mp4',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.edit_rounded,
                                      color: accent,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'MP4 • ${state.fileSize.isNotEmpty ? state.fileSize : 'Ready'}',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= 4. VIDEO ACTIONS (QA Bug vii Fix: ONLY Share & Download) =================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'VIDEO ACTIONS',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Exactly 2 Action Buttons
            Row(
              children: [
                // 1. Share
                Expanded(
                  child: _buildActionItem(
                    icon: Icons.ios_share_rounded,
                    label: 'Share',
                    accent: accent,
                    textColor: textColor,
                    isDark: isDark,
                    onTap: () {
                      final path = state.videoPath.isNotEmpty
                          ? state.videoPath
                          : widget.videoPath;
                      if (path.isNotEmpty) {
                        Share.shareXFiles([XFile(path)], text: 'My Cut Video');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Download
                Expanded(
                  child: _buildActionItem(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    accent: accent,
                    textColor: textColor,
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
              ],
            ),

            const SizedBox(height: 10),
            Text(
              'Actions apply to the trimmed video.',
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),

            const SizedBox(height: 24),

            // ================= 5. BACK TO HOME BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Back to home',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Clean 2-action pill widget
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color accent,
    required Color textColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Icon(icon, color: textColor, size: 24),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent, width: 1.2),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
