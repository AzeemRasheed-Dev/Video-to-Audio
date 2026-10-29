import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/features/audioCut/presentation/viewmodel/AudioCutViewModel.dart';
import 'package:my_app/src/features/output/model/output_file_item.dart';
import 'package:my_app/src/features/videoCut/presentation/viewmodel/video_cut_viewmodel.dart';

import '../viewmodel/output_viewmodel.dart';

class OutputScreen extends ConsumerWidget {
  const OutputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outputViewModelProvider);
    final vm = ref.read(outputViewModelProvider.notifier);
    final isDark = context.isDark;

    final bg = AppTokens.bg(isDark);
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final accent = const Color(0xFF266653); // Emerald Green Accent

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: Text(
            'Output files',
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: accent, size: 26),
              tooltip: 'Refresh',
              onPressed: vm.loadFiles,
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: accent,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: accent,
            unselectedLabelColor: textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Audio'),
              Tab(text: 'Video'),
            ],
          ),
        ),
        body: state.isLoading
            ? Center(child: CircularProgressIndicator(color: accent))
            : TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Tab 1: Audios (Kept Alive in Memory)
                  _KeepAliveTab(
                    child: _OutputFilesList(
                      items: state.audioFiles,
                      isVideo: false,
                      onRefresh: vm.loadFiles,
                      vm: vm,
                    ),
                  ),

                  // Tab 2: Videos (Kept Alive in Memory)
                  _KeepAliveTab(
                    child: _OutputFilesList(
                      items: state.videoFiles,
                      isVideo: true,
                      onRefresh: vm.loadFiles,
                      vm: vm,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ============================================================================
// 1. KEEP-ALIVE WRAPPER (Tabs Memory mein freeze rahenge, Zero Lag Switch)
// ============================================================================
class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Tab switch hone par reload nahi hoga

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(child: widget.child);
  }
}

// ============================================================================
// 2. FILE LIST & SMOOTH EMPTY STATE WIDGET
// ============================================================================
class _OutputFilesList extends ConsumerWidget {
  final List<OutputFileItem> items;
  final bool isVideo;
  final Future<void> Function() onRefresh;
  final OutputViewModel vm;

  const _OutputFilesList({
    super.key,
    required this.items,
    required this.isVideo,
    required this.onRefresh,
    required this.vm,
  });

  // 👉 File Pick karke respective Cut Screen par jane ka method
  Future<void> _handleEmptyAction(BuildContext context, WidgetRef ref) async {
    if (isVideo) {
      // 1. Video Pick karein aur VideoCutScreen2 par jayein
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        final file = result.files.first;
        await ref
            .read(videoCutViewModelProvider.notifier)
            .initVideo(file.path!, file.name);

        if (context.mounted) {
          context.push(AppRoutes.videoCut2);
        }
      }
    } else {
      // 2. Audio Pick karein aur AudioCutScreen par jayein
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        final file = result.files.first;
        await ref
            .read(audioCutViewModelProvider.notifier)
            .initAudio(file.path!, file.name);

        if (context.mounted) {
          context.push(AppRoutes.audioCut);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final cardBg = isDark ? const Color(0xFF1E2824) : Colors.white;
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final border = AppTokens.border(isDark);
    final accent = const Color(0xFF266653);

    // ================= EMPTY STATE =================
    if (items.isEmpty) {
      final iconBg = isDark ? const Color(0xFF1E2824) : const Color(0xFFEBF2EE);
      final emptyTitle = isVideo ? 'No videos yet' : 'No audio yet';
      final emptySubtitle = isVideo
          ? 'Your trimmed videos will appear here.'
          : 'Converted and trimmed audio\nwill appear here.';
      final btnLabel = isVideo ? 'Trim a video' : 'Create audio';

      return RefreshIndicator(
        onRefresh: onRefresh,
        color: accent,
        backgroundColor: cardBg,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SizedBox(height: 50),

            // Green Square Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    isVideo
                        ? Icons.movie_creation_outlined
                        : Icons.graphic_eq_rounded,
                    color: accent,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Center(
              child: Text(
                emptyTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Center(
              child: Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Action Button (Cut Audio ya Trim Video open karega)
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleEmptyAction(context, ref),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    child: Text(
                      btnLabel,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Bottom Sponsor Card
            _buildSponsorCard(cardBg, textColor, textSecondary, accent, border),
          ],
        ),
      );
    }

    // ================= LIST OF FILES =================
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: accent,
      backgroundColor: cardBg,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final file = items[index];
          return _buildFileCard(
            file: file,
            context: context,
            cardBg: cardBg,
            textColor: textColor,
            textSecondary: textSecondary,
            border: border,
            accent: accent,
          );
        },
      ),
    );
  }

  // --- Themed File Card ---
  Widget _buildFileCard({
    required OutputFileItem file,
    required BuildContext context,
    required Color cardBg,
    required Color textColor,
    required Color textSecondary,
    required Color border,
    required Color accent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            file.isVideo
                ? Icons.movie_creation_outlined
                : Icons.audiotrack_rounded,
            color: accent,
            size: 24,
          ),
        ),
        title: Text(
          file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${file.formattedSize} • ${file.formattedDate}',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
        ),
        onTap: () => vm.openFile(file),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Share
            IconButton(
              icon: Icon(Icons.share_outlined, color: textSecondary, size: 20),
              onPressed: () => vm.shareFile(file),
            ),
            // Popup Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textSecondary, size: 20),
              color: cardBg,
              onSelected: (val) {
                if (val == 'open') {
                  vm.openFile(file);
                } else if (val == 'delete') {
                  _showDeleteConfirm(
                    context,
                    file,
                    cardBg,
                    textColor,
                    textSecondary,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Open', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Sponsor Card Widget ---
  Widget _buildSponsorCard(
    Color cardBg,
    Color textColor,
    Color textSecondary,
    Color accent,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ad • Sample sponsor',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Sponsored content',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Text(
                  'Learn more',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Delete Dialog ---
  void _showDeleteConfirm(
    BuildContext context,
    OutputFileItem file,
    Color cardBg,
    Color textColor,
    Color textSecondary,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete File?',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${file.name}"?',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteFile(file);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('File deleted successfully'),
                ),
              );
            },
            child: const Text(
              'Delete',
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
}
