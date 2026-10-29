import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const home = '/home';
  static const settings = '/settings';
  static const videoToAudio = '/video-to-audio';
  static const String videoCut = '/video-cut';
  static const String conversionResult = '/conversion-result';
  static const String audioCut = '/audio-cut';
  static const String audioSaved = '/audio-saved';
  static const String videoCut2 = '/video-cut2';
  static const String videoSaved = '/video-saved';
}

abstract class AppRoute {
  const AppRoute();

  String get location;

  void go(BuildContext context) => context.go(location);
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);
}

class SplashRoute extends AppRoute {
  const SplashRoute();
  @override
  String get location => AppRoutes.splash;
}

class HomeRoute extends AppRoute {
  const HomeRoute();
  @override
  String get location => AppRoutes.home;
}

class SettingsRoute extends AppRoute {
  const SettingsRoute();
  @override
  String get location => AppRoutes.settings;
}


class VideoToAudioRoute extends AppRoute {
  const VideoToAudioRoute();
  @override
  String get location => AppRoutes.videoToAudio;
}
