import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/features/audioCut/presentation/screens/AudioCutScreen.dart';
import 'package:my_app/src/features/audioCut/presentation/screens/audio_saved_screen.dart';
import 'package:my_app/src/features/home/presntation/screen/conversion_result_screen.dart';
import 'package:my_app/src/features/home/presntation/screen/videoCut_screen.dart';
import 'package:my_app/src/features/home/presntation/screen/video_to_audio_screen.dart';
import 'package:my_app/src/features/navigation/presntation/screens/main_navigation_screen.dart';
import 'package:my_app/src/features/startup/presntation/screens/splash_screen.dart';
import 'package:my_app/src/features/videoCut/presentation/screens/videoCut_screen2.dart';
import 'package:my_app/src/features/videoCut/presentation/screens/video_saved_screen.dart';

import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            _fadePage(state, child: const SplashScreen()),
      ),

      // 👉 Ab Home par MainNavigationScreen khulegi (Bottom Bar ke sath):
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            _fadePage(state, child: const MainNavigationScreen()),
      ),

      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _slidePage(
          state,
          child: const Scaffold(body: Center(child: Text("Settings Screen"))),
        ),
      ),
      GoRoute(
        path: AppRoutes.videoToAudio,
        pageBuilder: (context, state) =>
            _slidePage(state, child: const VideoToAudioScreen()),
      ),
      GoRoute(
        path: AppRoutes.conversionResult,
        pageBuilder: (context, state) =>
            _slidePage(state, child: const ConversionResultScreen()),
      ),
      GoRoute(
        path: AppRoutes.audioCut,
        pageBuilder: (context, state) =>
            _slidePage(state, child: const AudioCutScreen()),
      ),
      GoRoute(
        path: AppRoutes.audioSaved,
        pageBuilder: (context, state) {
          final audioPath = state.extra as String;
          return _slidePage(
            state,
            child: AudioSavedScreen(audioPath: audioPath),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.videoCut,
        pageBuilder: (context, state) =>
            _slidePage(state, child: const VideoCutScreen()),
      ),
      GoRoute(
        path: AppRoutes.videoCut2,
        pageBuilder: (context, state) =>
            _slidePage(state, child: const VideoCutScreen2()),
      ),
      GoRoute(
        path: AppRoutes.videoSaved,
        pageBuilder: (context, state) {
          final videoPath = state.extra as String;
          return _slidePage(
            state,
            child: VideoSavedScreen(videoPath: videoPath),
          );
        },
      ),
    ],
  );
});

// Smooth Fade Transition
CustomTransitionPage<void> _fadePage(
  GoRouterState state, {
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 250),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// Smooth Slide Transition
CustomTransitionPage<void> _slidePage(
  GoRouterState state, {
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}