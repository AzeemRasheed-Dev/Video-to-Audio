import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

class VideoToAudioApp extends ConsumerWidget {
  const VideoToAudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Router watch karein
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Video to Audio Converter',
      debugShowCheckedModeBanner: false,

      // // 2. Hamara banaya hua Theme:
      // themeMode: ThemeMode.dark, // Default Dark Theme
      // darkTheme: AppTheme.darkTheme,

      // 3. GoRouter config:
      routerConfig: router,
    );
  }
}