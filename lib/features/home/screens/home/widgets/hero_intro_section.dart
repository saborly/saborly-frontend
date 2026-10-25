import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/constant/app_typography.dart';
import 'package:Saborly/core/routes/app_routes.dart';
import 'package:Saborly/features/home/widgets/web/web_google_reviews_section.dart';

/// Real Saborly food shots (poster frames of the brand videos, bundled with
/// the app, so the hero never waits on the network).
const _heroPhotoMain = 'assets/videos/posters/saborly_come_eat_now.jpg';
const _heroPhotoSide = 'assets/videos/posters/saborly_taste_of_pakistan.jpg';
const _heroPhotoSideAlt = 'assets/videos/posters/saborly_family_moments.jpg';

const _heroGradient = LinearGradient(
  colors: [Color(0xFF2A1611), Color(0xFF4A1D12), Color(0xFF7B2F17)],
  stops: [0, 0.55, 1],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Home brand band: headline, order/offers CTAs and trust stats (live Google
/// rating, delivery time, menu size) next to real food photography — a
/// photo collage on web, a single photo fading in behind the copy on mobile.
class HeroIntroSection extends StatelessWidget {
  final bool isWeb;
  final VoidCallback onClearSearchSilently;

  const HeroIntroSection({
    super.key,
    required this.isWeb,
    required this.onClearSearchSilently,
  });

  void _orderNow(BuildContext context) {
    onClearSearchSilently();
    context.go(AppRoutes.menu);
  }

  void _viewOffers(BuildContext context) {
    onClearSearchSilently();
    context.go(AppRoutes.offer);
  }

  @override
  Widget build(BuildContext context) {
    final ctas = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _HeroButton(
          label: AppStrings.get('homeHeroOrderNow'),
          icon: Icons.arrow_forward_rounded,
          filled: true,
          large: isWeb,
          onTap: () => _orderNow(context),
        ),
        _HeroButton(
          label: AppStrings.get('homeHeroViewOffers'),
          icon: Icons.local_offer_outlined,
          filled: false,
          large: isWeb,
          onTap: () => _viewOffers(context),
        ),
      ],
    );

    return isWeb ? _WebHero(ctas: ctas) : _MobileHero(ctas: ctas);
  }
}

class _WebHero extends StatelessWidget {
  final Widget ctas;

  const _WebHero({required this.ctas});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showPhotos = constraints.maxWidth >= 860;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _heroGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: AppColors.accentNight.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 18)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const Positioned(left: -120, top: -160, child: _Glow(size: 420)),
              Padding(
                padding: const EdgeInsets.all(48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _HeroBadge(),
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.get('homeHeroTitle'),
                            style: AppTypography.display(44, color: Colors.white, height: 1.12),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Text(
                              AppStrings.get('homeHeroSubtitle'),
                              style: AppTypography.body(16, color: Colors.white.withValues(alpha: 0.78), height: 1.55),
                            ),
                          ),
                          const SizedBox(height: 28),
                          ctas,
                          const SizedBox(height: 36),
                          const _HeroStats(compact: false),
                        ],
                      ),
                    ),
                    if (showPhotos) ...[
                      const SizedBox(width: 48),
                      const Expanded(flex: 9, child: _PhotoCollage(height: 400)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MobileHero extends StatelessWidget {
  final Widget ctas;

  const _MobileHero({required this.ctas});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accentNight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.accentNight.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Photo on the right, fading into the dark panel behind the copy.
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 190,
            child: Image.asset(_heroPhotoMain, fit: BoxFit.cover, alignment: const Alignment(0, -0.1)),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2A1611), Color(0xF22A1611), Color(0x662A1611)],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroBadge(),
                const SizedBox(height: 14),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Text(
                    AppStrings.get('homeHeroTitle'),
                    style: AppTypography.display(23, color: Colors.white, height: 1.15),
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Text(
                    AppStrings.get('homeHeroSubtitle'),
                    style: AppTypography.body(13, color: Colors.white.withValues(alpha: 0.8), height: 1.45),
                  ),
                ),
                const SizedBox(height: 18),
                ctas,
                const SizedBox(height: 18),
                const _HeroStats(compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: AppTypography.size(14), color: AppColors.secondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              AppStrings.get('homeHeroBadge'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(12, color: AppColors.secondaryLight, weight: FontWeight.w800, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rating (live from Google, shown only once it has loaded), average
/// delivery time and menu size, separated by hairlines.
class _HeroStats extends StatefulWidget {
  final bool compact;

  const _HeroStats({required this.compact});

  @override
  State<_HeroStats> createState() => _HeroStatsState();
}

class _HeroStatsState extends State<_HeroStats> {
  late final Future<List<GooglePlaceSummary>> _places = loadGooglePlaces();

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;

    return FutureBuilder<List<GooglePlaceSummary>>(
      future: _places,
      builder: (context, snapshot) {
        final summary = googleRatingSummary(snapshot.data ?? const []);
        final stats = [
          if (summary != null)
            _Stat(Icons.star_rounded, summary.rating.toStringAsFixed(1), AppStrings.get('homeStatGoogleRating')),
          _Stat(Icons.timer_outlined, AppStrings.get('homeStatDeliveryValue'), AppStrings.get('homeStatDelivery')),
          _Stat(Icons.restaurant_menu_rounded, '150+', AppStrings.get('homeStatDishes')),
        ];

        final divider = Container(
          width: 1,
          height: compact ? 34 : 40,
          margin: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
          color: Colors.white.withValues(alpha: 0.14),
        );

        final children = <Widget>[
          for (int i = 0; i < stats.length; i++) ...[
            if (i > 0) divider,
            compact ? Expanded(child: _StatView(stat: stats[i], compact: true)) : _StatView(stat: stats[i], compact: false),
          ],
        ];

        return Row(mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min, children: children);
      },
    );
  }
}

class _Stat {
  final IconData icon;
  final String value;
  final String label;

  const _Stat(this.icon, this.value, this.label);
}

class _StatView extends StatelessWidget {
  final _Stat stat;
  final bool compact;

  const _StatView({required this.stat, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stat.icon, size: AppTypography.size(compact ? 14 : 18), color: AppColors.secondary),
            SizedBox(width: compact ? 4 : 6),
            Text(stat.value, style: AppTypography.heading(compact ? 16 : 22, color: Colors.white, height: 1.1)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          stat.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(compact ? 10.5 : 12.5, color: Colors.white.withValues(alpha: 0.65), weight: FontWeight.w600, height: 1.3),
        ),
      ],
    );
  }
}

/// One tall photo beside two stacked ones.
class _PhotoCollage extends StatelessWidget {
  final double height;

  const _PhotoCollage({required this.height});

  @override
  Widget build(BuildContext context) {
    const gap = 14.0;
    return SizedBox(
      height: height,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: _Photo(_heroPhotoMain, alignment: Alignment(0, -0.1))),
          SizedBox(width: gap),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Photo(_heroPhotoSide, alignment: Alignment(0, -0.25))),
                SizedBox(height: gap),
                Expanded(child: _Photo(_heroPhotoSideAlt, alignment: Alignment(0, 0.1))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final String asset;
  final Alignment alignment;

  const _Photo(this.asset, {this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: alignment,
              errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.primaryDark),
            ),
            // Hairline inner edge so photos sit crisply on the dark band.
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft warm light behind the headline.
class _Glow extends StatelessWidget {
  final double size;

  const _Glow({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppColors.primary.withValues(alpha: 0.35), AppColors.primary.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _HeroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool large;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.large,
    required this.onTap,
  });

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.filled;
    final foreground = filled ? AppColors.primaryDark : Colors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: widget.large ? 26 : 18, vertical: widget.large ? 16 : 12),
          decoration: BoxDecoration(
            color: filled
                ? (_hovering ? AppColors.secondaryLight : Colors.white)
                : Colors.white.withValues(alpha: _hovering ? 0.12 : 0),
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTypography.body(widget.large ? 15.5 : 14, color: foreground, weight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: AppTypography.size(widget.large ? 18 : 16), color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
