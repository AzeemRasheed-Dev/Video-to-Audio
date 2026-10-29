import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  // Google ki Official Android Native Test Ad Unit ID:
  static const String _adUnitId = 'ca-app-pub-3940256099942544/2247696110';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nativeAd == null) {
      _loadNativeAd();
    }
  }

  void _loadNativeAd() {
    final isDark = context.isDark;
    final cardBg = AppTokens.card(isDark);
    final accent = AppTokens.accent(isDark);
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);

    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _nativeAd = null;
            });
          }
        },
      ),
      // 👉 Emerald Green Design System ke mutabiq Styled Native Template:
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: cardBg,
        cornerRadius: 14.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: accent,
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: textColor,
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: textSecondary,
          size: 11.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: textSecondary,
          size: 10.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // 1. Agar Google Ad successfully load ho jaye tou Real Native Ad dikhayein:
    if (_isLoaded && _nativeAd != null) {
      return Container(
        height: 94,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTokens.card(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTokens.border(isDark)),
        ),
        clipBehavior: Clip.antiAlias,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    // 2. Loading / Fallback UI (taake screen flicker na kare)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTokens.card(isDark).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.border(isDark)),
      ),
      child: Row(
        children: [
          // 1. Sponsor Logo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTokens.accent(isDark).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.eco_rounded,
              color: AppTokens.accent(isDark),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 2. Ad Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.border(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Ad',
                        style: TextStyle(
                          color: AppTokens.textSecondary(isDark),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sample sponsor',
                      style: TextStyle(
                        color: AppTokens.text(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Sponsored content',
                  style: TextStyle(
                    color: AppTokens.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // 3. Action Button
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTokens.accent(isDark)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Learn more',
              style: TextStyle(
                color: AppTokens.accent(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
