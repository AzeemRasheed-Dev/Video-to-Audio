import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/features/audioCut/presentation/viewmodel/AudioCutViewModel.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/converter_providers.dart';
import 'package:my_app/src/features/home/widjets/native_ad_card.dart';
import 'package:my_app/src/features/home/widjets/tool_card.dart';
import 'package:my_app/src/features/videoCut/presentation/viewmodel/video_cut_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 Native Permission Package

import '../../../../core/theme/app_tokens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// 👉 Android ka Official Native System Dialog ("Allow / Don't allow") trigger karega
  Future<bool> _checkAndRequestPermission({required bool isVideo}) async {
    if (!Platform.isAndroid) return true;

    // Android 13+ (API 33+) ke liye specific permissions:
    final Permission primaryPerm = isVideo
        ? Permission.videos
        : Permission.audio;

    var status = await primaryPerm.status;
    if (status.isGranted || status.isLimited) return true;

    // Native Android System Dialog kholay ga:
    status = await primaryPerm.request();
    if (status.isGranted || status.isLimited) return true;

    // Purane Android (Android 12 aur is se pehle) ke liye fallback Storage permission:
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final width = context.screenWidth;

    return Scaffold(
      backgroundColor: AppTokens.bg(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTokens.screenPadding(width).copyWith(top: 16, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Title, Subtitle & PRO Badge)
              _buildHeader(context, isDark, width),

              const SizedBox(height: AppTokens.s24),

              // 2. Section Label
              Text(
                'YOUR TOOLS',
                style: TextStyle(
                  color: AppTokens.textSecondary(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: AppTokens.s12),

              // 3. Tool 01: Video to Audio
              ToolCard(
                number: '01',
                title: 'Video to Audio',
                subtitle: 'Extract sound from any video',
                graphic: ToolGraphics.videoToAudio(context),
                onTap: () async {
                  // 👉 1. Android ka Native "Allow" dialog khulay ga:
                  final hasPermission = await _checkAndRequestPermission(
                    isVideo: true,
                  );
                  if (!hasPermission) return;

                  // 👉 2. Allow hone ke baad Gallery khulegi:
                  await ref
                      .read(converterViewModelProvider.notifier)
                      .pickVideo();
                  if (context.mounted &&
                      ref.read(converterViewModelProvider).videoPath != null) {
                    await context.push(AppRoutes.videoToAudio);
                    // Back aane par reset karega (Bug 3 Fix):
                    ref.read(converterViewModelProvider.notifier).reset();
                  }
                },
              ),

              const SizedBox(height: AppTokens.s16),

              // 4. Tool 02: Audio Cutter
              ToolCard(
                number: '02',
                title: 'Audio Cutter',
                subtitle: 'Keep just the part you need',
                graphic: ToolGraphics.audioCutter(context),
                onTap: () async {
                  // 👉 1. Android ka Native Audio permission dialog khulay ga:
                  final hasPermission = await _checkAndRequestPermission(
                    isVideo: false,
                  );
                  if (!hasPermission) return;

                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.audio,
                  );
                  if (result != null && result.files.single.path != null) {
                    final file = result.files.single;

                    context.push(AppRoutes.audioCut);
                    ref
                        .read(audioCutViewModelProvider.notifier)
                        .initAudio(file.path!, file.name);
                  }
                },
              ),

              const SizedBox(height: AppTokens.s16),

              // 5. Tool 03: Video Cutter
              ToolCard(
                number: '03',
                title: 'Video Cutter',
                subtitle: 'Trim your video with precision',
                graphic: ToolGraphics.videoCutter(context),
                onTap: () async {
                  // 👉 1. Android ka Native "Allow" dialog khulay ga:
                  final hasPermission = await _checkAndRequestPermission(
                    isVideo: true,
                  );
                  if (!hasPermission) return;

                  final ImagePicker picker = ImagePicker();
                  final XFile? file = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (file != null) {
                    await ref
                        .read(videoCutViewModelProvider.notifier)
                        .initVideo(file.path, file.name);
                    if (context.mounted) {
                      context.push(AppRoutes.videoCut2);
                    }
                  }
                },
              ),

              const SizedBox(height: AppTokens.s20),

              // 6. Native Sponsor Ad
              const NativeAdCard(),

              const SizedBox(height: AppTokens.s16),

              // 7. Footer Hint
              Center(
                child: Text(
                  'Choose a tool to get started',
                  style: TextStyle(
                    color: AppTokens.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video to Audio',
              style: TextStyle(
                color: AppTokens.text(isDark),
                fontSize: AppTokens.h1(width),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Make every clip useful.',
              style: TextStyle(
                color: AppTokens.textSecondary(isDark),
                fontSize: AppTokens.body(width),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTokens.accent(isDark), width: 1.2),
          ),
          child: Text(
            'PRO',
            style: TextStyle(
              color: AppTokens.accent(isDark),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
