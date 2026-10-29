import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashViewModelProvider = StateNotifierProvider<SplashViewModel, bool>((
  ref,
) {
  return SplashViewModel();
});

class SplashViewModel extends StateNotifier<bool> {
  SplashViewModel() : super(false) {
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 4500));

    state = true;
  }
}
