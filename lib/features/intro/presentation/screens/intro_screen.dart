import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/intro_illustration.dart';

/// Welcome slides shown once to guests before the public video library.
final class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

final class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _floatController;
  int _page = 0;

  static const _pageCount = 3;

  bool get _isLastPage => _page == _pageCount - 1;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await sl<ILocalStorage>().setBool(StorageKeys.introSeen, value: true);
    if (!mounted) return;
    context.go(AppRoutes.videoLibrary);
  }

  List<_IntroPageData> _pages(BuildContext context) {
    final l10n = context.l10n;
    return [
      _IntroPageData(
        tag: l10n.introPage1Tag,
        title: l10n.introPage1Title,
        body: l10n.introPage1Body,
        icon: Icons.fitness_center_rounded,
        badges: const [Iconsax.heart, Iconsax.flash, Iconsax.medal_star],
      ),
      _IntroPageData(
        tag: l10n.introPage2Tag,
        title: l10n.introPage2Title,
        body: l10n.introPage2Body,
        icon: Iconsax.video_play,
        badges: const [Iconsax.man, Iconsax.woman, Iconsax.play_circle],
      ),
      _IntroPageData(
        tag: l10n.introPage3Tag,
        title: l10n.introPage3Title,
        body: l10n.introPage3Body,
        icon: Iconsax.unlock,
        badges: const [Iconsax.mobile, Iconsax.timer_1, Iconsax.star_1],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.neutral1000,
        body: Stack(
          children: [
            const Positioned.fill(child: _IntroBackground()),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                    child: Row(
                      children: [
                        const _Wordmark(),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: _isLastPage ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: TextButton(
                            onPressed: _isLastPage ? null : _finish,
                            child: Text(
                              context.l10n.introSkip,
                              style: context.subtitleMedium.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (page) => setState(() => _page = page),
                      itemBuilder: (_, index) => _IntroPage(
                        data: pages[index],
                        floatAnimation: _floatController,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        _PageIndicator(count: pages.length, current: _page),
                        28.vertical,
                        AppButton(
                          label: _isLastPage
                              ? context.l10n.introGetStarted
                              : context.l10n.introNext,
                          onPressed: _onNext,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _IntroPageData {
  const _IntroPageData({
    required this.tag,
    required this.title,
    required this.body,
    required this.icon,
    required this.badges,
  });

  final String tag;
  final String title;
  final String body;
  final IconData icon;
  final List<IconData> badges;
}

final class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.data, required this.floatAnimation});

  final _IntroPageData data;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: IntroIllustration(
                icon: data.icon,
                badges: data.badges,
                floatAnimation: floatAnimation,
              ),
            ),
          ),
          _TagPill(label: data.tag),
          16.vertical,
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: context.heading3.copyWith(
              color: AppColors.white,
              height: 1.3,
            ),
          ),
          12.vertical,
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: context.contentRegular.copyWith(
              color: AppColors.neutral400,
              height: 1.6,
            ),
          ),
          12.vertical,
        ],
      ),
    );
  }
}

final class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: context.footnoteSemiboldBold.copyWith(color: AppColors.primary),
      ),
    );
  }
}

final class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? AppColors.primary : AppColors.neutral800,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

final class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.5,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'GLORY ',
            style: style.copyWith(color: AppColors.white),
          ),
          TextSpan(
            text: 'GYM',
            style: style.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

final class _IntroBackground extends StatelessWidget {
  const _IntroBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.45),
          radius: 0.9,
          colors: [Color(0x40FEB825), Color(0x0AFEB825), Color(0x00000000)],
          stops: [0, 0.55, 1],
        ),
      ),
    );
  }
}
