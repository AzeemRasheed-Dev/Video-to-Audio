import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/features/home/presntation/screen/homeScreen.dart';
import 'package:my_app/src/features/navigation/viewmodel/bottom_nav_provider.dart';
import 'package:my_app/src/features/output/presntation/screens/output_screen.dart';

import '../widgets/custom_bottom_bar.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isDark = context.isDark;

    final bg = AppTokens.bg(isDark);
    final textColor = AppTokens.text(isDark);

    // Dynamic screens list jo Theme Mode change hone par foran update hogi
    final List<Widget> screens = [
      const HomeScreen(),
      const OutputScreen(),
      // Themed Settings Screen
      Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: Text(
            'Settings',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Settings Screen',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: bg, // 👈 Theme-synced Background
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
