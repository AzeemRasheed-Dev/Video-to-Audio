import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/features/startup/presntation/viemodel/splash_viewmodel.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_tokens.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Bottom music wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(splashViewModelProvider, (previous, isReady) {
      if (isReady) {
        const HomeRoute().go(context);
      }
    });

    final isDark = context.isDark;
    final bg = AppTokens.bg(isDark);
    final accent = AppTokens.accent(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ================= 1. CENTER CARDS WITH PARTICLES =================
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Floating Particles (Brand Emerald, Mint & Subtle Gold)
                  _buildParticle(
                    top: 36,
                    left: 28,
                    color: accent,
                    size: 10,
                    isStar: true,
                  ),
                  _buildParticle(
                    top: 92,
                    left: 12,
                    color: const Color(0xFF3DB58B),
                    size: 6,
                  ),
                  _buildParticle(
                    bottom: 48,
                    left: 68,
                    color: isDark ? Colors.white24 : Colors.black12,
                    size: 5,
                  ),
                  _buildParticle(
                    top: 76,
                    right: 18,
                    color: const Color(0xFFFFB300),
                    size: 8,
                    isStar: true,
                  ),
                  _buildParticle(
                    top: 84,
                    right: -12,
                    color: accent,
                    size: 9,
                    isHollow: true,
                  ),
                  _buildParticle(
                    bottom: 68,
                    right: 32,
                    color: const Color(0xFF67CCA9),
                    size: 6,
                  ),

                  // Back Card (Secondary Media Card)
                  Transform.translate(
                    offset: const Offset(15, 0),
                    child: Transform.rotate(
                      angle: 0.12,
                      child: Container(
                        width: 72,
                        height: 90,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1B2923)
                              : const Color(0xFFE2EDE7),
                          borderRadius: BorderRadius.circular(AppTokens.s16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFCCE0D6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.motion_photos_on_outlined,
                            color: isDark
                                ? const Color(0xFF52B795).withValues(alpha: 0.6)
                                : accent.withValues(alpha: 0.5),
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Front Card (Emerald Green Music Note Card)
                  Transform.translate(
                    offset: const Offset(-15, 0),
                    child: Transform.rotate(
                      angle: -0.06,
                      child: Container(
                        width: 72,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF266653), Color(0xFF194A3B)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(AppTokens.s16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF266653,
                              ).withValues(alpha: isDark ? 0.45 : 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= 2. BOTTOM ANIMATED MUSIC WAVE (EQUALIZER) =================
          Positioned(
            bottom: AppTokens.s60,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWaveBar(
                      14 + (10 * _waveController.value),
                      const Color(0xFF1E5E4A),
                    ),
                    _buildWaveBar(
                      24 - (12 * _waveController.value),
                      const Color(0xFF266653),
                    ),
                    _buildWaveBar(
                      18 + (8 * (1 - _waveController.value)),
                      const Color(0xFF348E73),
                    ),
                    _buildWaveBar(
                      22 - (10 * _waveController.value),
                      const Color(0xFF4EBA97),
                    ),
                    _buildWaveBar(
                      12 + (14 * _waveController.value),
                      const Color(0xFF7ED8BA),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Equalizer Bar Helper
  Widget _buildWaveBar(double height, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      width: 4.5,
      height: height.clamp(8.0, 30.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTokens.s4),
      ),
    );
  }

  // Floating Particle Helper
  Widget _buildParticle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
    bool isStar = false,
    bool isHollow = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: isStar
          ? Icon(Icons.star_rounded, color: color, size: size)
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHollow ? Colors.transparent : color,
                border: isHollow ? Border.all(color: color, width: 1.6) : null,
              ),
            ),
    );
  }
}
