import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/features/navigation/viewmodel/bottom_nav_provider.dart';

class CustomBottomBar extends ConsumerWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isDark = context.isDark;

    final bg = AppTokens.bg(isDark);
    final border = AppTokens.border(isDark);
    final accent = AppTokens.accent(isDark);
    final inactiveColor = AppTokens.textSecondary(isDark);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: border, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _buildNavItem(
                ref: ref,
                index: 0,
                currentIndex: currentIndex,
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: 'Home',
                accent: accent,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                ref: ref,
                index: 1,
                currentIndex: currentIndex,
                activeIcon: Icons.folder_rounded,
                inactiveIcon: Icons.folder_outlined,
                label: 'Output',
                accent: accent,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                ref: ref,
                index: 2,
                currentIndex: currentIndex,
                activeIcon: Icons.settings_rounded,
                inactiveIcon: Icons.settings_outlined,
                label: 'Settings',
                accent: accent,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required int index,
    required int currentIndex,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required Color accent,
    required Color inactiveColor,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected ? accent : inactiveColor;
    final icon = isSelected ? activeIcon : inactiveIcon;

    return Expanded(
      child: InkWell(
        onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 