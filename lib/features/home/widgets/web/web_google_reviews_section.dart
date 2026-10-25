import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/constant/app_typography.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/core/utils/time_utils.dart';

/// One Google Place's rating/review summary, as returned by
/// `GET /api/v1/reviews/google` on the backend (which proxies Google Places
/// server-side so the API key never reaches the client).
class GooglePlaceSummary {
  final String name;
  final String location;
  final double? rating;
  final int reviewCount;
  final String? priceRange;
  final String category;
  final String? mapsUrl;
  final List<GoogleReviewSnippet> reviews;

  const GooglePlaceSummary({
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.priceRange,
    required this.category,
    this.mapsUrl,
    required this.reviews,
  });

  factory GooglePlaceSummary.fromJson(Map<String, dynamic> json) {
    return GooglePlaceSummary(
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      priceRange: json['priceRange']?.toString(),
      category: json['category']?.toString() ?? '',
      mapsUrl: json['mapsUrl']?.toString(),
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => GoogleReviewSnippet.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GoogleReviewSnippet {
  final String author;
  final String? authorPhoto;
  final String text;
  final int rating;
  final String relativeTime;

  const GoogleReviewSnippet({
    required this.author,
    this.authorPhoto,
    required this.text,
    required this.rating,
    this.relativeTime = '',
  });

  factory GoogleReviewSnippet.fromJson(Map<String, dynamic> json) {
    return GoogleReviewSnippet(
      author: json['author']?.toString() ?? '',
      authorPhoto: json['authorPhoto']?.toString(),
      text: json['text']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      relativeTime: json['relativeTime']?.toString() ?? '',
    );
  }
}

const _retryDelays = [Duration(seconds: 2), Duration(seconds: 5)];
Future<List<GooglePlaceSummary>>? _placesRequest;

/// Live Google data for every active branch — fetched once per session and
/// shared by the hero's rating stat and [WebGoogleReviewsSection].
///
/// An empty result means the request failed (timeout, rate limit, Google
/// lookup error) — every active branch has a listing — so it retries a
/// couple of times, and isn't kept, so a later visit can try again.
Future<List<GooglePlaceSummary>> loadGooglePlaces() {
  return _placesRequest ??= () async {
    var raw = await ApiService().fetchGoogleReviews();
    for (final delay in _retryDelays) {
      if (raw.isNotEmpty) break;
      await Future.delayed(delay);
      raw = await ApiService().fetchGoogleReviews();
    }
    final places = raw.map(GooglePlaceSummary.fromJson).toList();
    if (places.isEmpty) _placesRequest = null;
    return places;
  }();
}

/// Review-count-weighted average rating across all branches, and the total
/// review count — or null when no branch has a rating.
({double rating, int reviewCount})? googleRatingSummary(List<GooglePlaceSummary> places) {
  final rated = places.where((p) => p.rating != null && p.reviewCount > 0).toList();
  final total = rated.fold<int>(0, (sum, p) => sum + p.reviewCount);
  if (total == 0) return null;
  final weighted = rated.fold<double>(0, (sum, p) => sum + p.rating! * p.reviewCount);
  return (rating: weighted / total, reviewCount: total);
}

enum _OpenState { open, closingSoon, closed }

/// Open/closed status for the branch cards, derived from the same schedule
/// ([TimeUtils], Spain time) that gates checkout — so the badge always agrees
/// with whether an order can actually be placed. Google's `open_now` isn't
/// used: it's missing for some listings and would be stale behind the
/// backend's 12h cache.
///
/// Holds raw times only; [detail] is rendered at build time so it follows
/// the current language.
class _OpenStatus {
  final _OpenState state;

  /// Today's closing time as "HH:mm" ("24:00" = midnight) while open.
  final String? closesAt;

  /// Next opening time while closed.
  final DateTime? opensAt;

  const _OpenStatus(this.state, {this.closesAt, this.opensAt});

  static const _closingSoonWindow = Duration(minutes: 60);

  factory _OpenStatus.now() {
    final untilClose = TimeUtils.durationUntilClosing();
    if (untilClose != null) {
      return _OpenStatus(
        untilClose <= _closingSoonWindow ? _OpenState.closingSoon : _OpenState.open,
        closesAt: TimeUtils.getTodayHours()?['close'],
      );
    }
    return _OpenStatus(_OpenState.closed, opensAt: TimeUtils.getNextOpeningTime());
  }

  /// e.g. "Closes at 23:00", "Opens tomorrow at 12:00" — in [languageCode].
  String detail(String languageCode) {
    String time(DateTime t) => _formatDate(DateFormat.jm, languageCode, t);

    final close = closesAt;
    if (close != null) {
      if (close == '24:00') return AppStrings.get('homeClosesAtMidnight');
      final parts = close.split(':');
      final closeTime = DateTime(2000, 1, 1, int.tryParse(parts[0]) ?? 0, int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0);
      return AppStrings.get('homeClosesAt').replaceAll('{time}', time(closeTime));
    }

    final next = opensAt;
    if (next == null) return '';
    final spainNow = TimeUtils.getSpainTime();
    final daysAway = DateTime.utc(next.year, next.month, next.day)
        .difference(DateTime.utc(spainNow.year, spainNow.month, spainNow.day))
        .inDays;
    final template = switch (daysAway) {
      0 => AppStrings.get('homeOpensTodayAt'),
      1 => AppStrings.get('homeOpensTomorrowAt'),
      _ => AppStrings.get('homeOpensOnAt').replaceAll('{day}', _formatDate(DateFormat.EEEE, languageCode, next)),
    };
    return template.replaceAll('{time}', time(next));
  }

  @override
  bool operator ==(Object other) =>
      other is _OpenStatus && other.state == state && other.closesAt == closesAt && other.opensAt == opensAt;

  @override
  int get hashCode => Object.hash(state, closesAt, opensAt);
}

/// Formats [t] in [languageCode], falling back to English if that locale's
/// date symbols aren't available.
String _formatDate(DateFormat Function([dynamic locale]) format, String languageCode, DateTime t) {
  try {
    return format(languageCode).format(t);
  } catch (_) {
    return format('en').format(t);
  }
}

/// "What our guests say" — live rating/review data for each active branch.
/// Fails silently (renders nothing, [header] included) if the backend/API
/// key isn't available, so the page never shows a heading with no reviews.
class WebGoogleReviewsSection extends StatefulWidget {
  /// Shown above the cards, and hidden along with them when there's nothing
  /// to show.
  final Widget? header;

  const WebGoogleReviewsSection({super.key, this.header});

  @override
  State<WebGoogleReviewsSection> createState() => _WebGoogleReviewsSectionState();
}

class _WebGoogleReviewsSectionState extends State<WebGoogleReviewsSection> {
  late final Future<List<GooglePlaceSummary>> _future;
  late final Timer _statusTimer;
  _OpenStatus _status = _OpenStatus.now();

  @override
  void initState() {
    super.initState();
    _future = loadGooglePlaces();
    // Re-evaluate so the badge flips at opening/closing time without a reload.
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final next = _OpenStatus.now();
      if (next != _status) setState(() => _status = next);
    });
  }

  @override
  void dispose() {
    _statusTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GooglePlaceSummary>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _withHeader(SizedBox(height: 220.h, child: const Center(child: CircularProgressIndicator())));
        }

        final places = snapshot.data ?? [];
        if (places.isEmpty) return const SizedBox.shrink();

        return _withHeader(LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 900 ? 2 : 1;
          const gap = 20.0;
          final cardWidth = columns == 1 ? constraints.maxWidth : (constraints.maxWidth - gap) / 2;

          return Wrap(
            spacing: gap,
            runSpacing: 16,
            children: places.map((p) => SizedBox(width: cardWidth, child: _PlaceCard(place: p, status: _status))).toList(),
          );
        }));
      },
    );
  }

  Widget _withHeader(Widget child) {
    final header = widget.header;
    if (header == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, child],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final GooglePlaceSummary place;
  final _OpenStatus status;
  const _PlaceCard({required this.place, required this.status});

  @override
  Widget build(BuildContext context) {
    final quote = place.reviews.isNotEmpty ? place.reviews.first : null;
    final detail = status.detail(Localizations.localeOf(context).languageCode);
    final metaStyle = AppTypography.body(12.5, color: AppColors.muted, weight: FontWeight.w600, height: 1.3);

    return LayoutBuilder(builder: (context, constraints) {
      // On phones the badge sits under the name so it doesn't squeeze it to
      // "Saborly Barc…"; wider cards keep it top-right.
      final badgeBelowName = constraints.maxWidth < 420;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.premiumAccent, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.storefront_rounded, size: 22, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(16, color: AppColors.textDark, weight: FontWeight.w800, height: 1.3),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: AppTypography.size(13), color: AppColors.muted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              place.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(12.5, color: AppColors.muted, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      if (badgeBelowName) ...[
                        const SizedBox(height: 8),
                        _openBadge(),
                      ],
                    ],
                  ),
                ),
                if (!badgeBelowName) ...[
                  const SizedBox(width: 8),
                  _openBadge(),
                ],
              ],
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (place.rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: AppTypography.size(16), color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(place.rating!.toStringAsFixed(1), style: AppTypography.body(13.5, color: AppColors.textDark, weight: FontWeight.w800, height: 1.3)),
                      const SizedBox(width: 4),
                      Text('(${place.reviewCount})', style: metaStyle),
                    ],
                  ),
                if (place.priceRange != null) Text(place.priceRange!, style: metaStyle),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(place.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: metaStyle),
                ),
                if (detail.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, size: AppTypography.size(14), color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(detail, style: metaStyle),
                    ],
                  ),
              ],
            ),

            if (quote != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.premiumAccent, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        quote.rating,
                        (i) => Icon(Icons.star_rounded, size: AppTypography.size(14), color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${quote.text}"',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(13.5, color: AppColors.textDark, height: 1.45).copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Text('— ${quote.author}', style: AppTypography.body(12, color: AppColors.muted, weight: FontWeight.w700, height: 1.3)),
                  ],
                ),
              ),
            ],

            if (place.reviews.length > 1) ...[
              const SizedBox(height: 12),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showAllReviews(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.get('homeReadMoreReviews'),
                        style: AppTypography.body(13, color: AppColors.primary, weight: FontWeight.w800, height: 1.3),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: AppTypography.size(15), color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showAllReviews(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AllReviewsDialog(place: place),
    );
  }

  Widget _openBadge() {
    final (label, color) = switch (status.state) {
      _OpenState.open => (AppStrings.get('homeOpenNow'), AppColors.accentLeaf),
      _OpenState.closingSoon => (AppStrings.get('homeClosingSoon'), AppColors.warning),
      _OpenState.closed => (AppStrings.get('homeClosed'), AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.body(11.5, color: color, weight: FontWeight.w800, height: 1.2)),
        ],
      ),
    );
  }
}

/// Full review list for one place, opened from "Read more reviews". Sorted
/// highest-rated first, revealed a few at a time via "Load more" — Google's
/// Places Details API only ever returns up to 5 reviews per place (no
/// pagination on Google's side), so this paginates through that fixed set.
class _AllReviewsDialog extends StatefulWidget {
  final GooglePlaceSummary place;
  const _AllReviewsDialog({required this.place});

  @override
  State<_AllReviewsDialog> createState() => _AllReviewsDialogState();
}

class _AllReviewsDialogState extends State<_AllReviewsDialog> {
  static const int _pageSize = 3;
  late final List<GoogleReviewSnippet> _sortedReviews;
  int _visibleCount = _pageSize;

  GooglePlaceSummary get place => widget.place;

  @override
  void initState() {
    super.initState();
    _sortedReviews = [...place.reviews]..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Widget build(BuildContext context) {
    final visibleReviews = _sortedReviews.take(_visibleCount).toList();
    final hasMore = _visibleCount < _sortedReviews.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place.name, style: AppTypography.body(18, color: AppColors.textDark, weight: FontWeight.w800, height: 1.3)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (place.rating != null) ...[
                                  Icon(Icons.star_rounded, size: AppTypography.size(15), color: AppColors.secondary),
                                  const SizedBox(width: 3),
                                  Text(place.rating!.toStringAsFixed(1), style: AppTypography.body(13, color: AppColors.textDark, weight: FontWeight.w700, height: 1.3)),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  AppStrings.get('homeGoogleReviewsCount').replaceAll('{count}', '${place.reviewCount}'),
                                  style: AppTypography.body(12.5, color: AppColors.muted, height: 1.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    itemCount: visibleReviews.length + (hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    itemBuilder: (context, index) {
                      if (index >= visibleReviews.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () => setState(() => _visibleCount += _pageSize),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppStrings.get('homeLoadMore'), style: AppTypography.body(13.5, weight: FontWeight.w800, height: 1.3)),
                                const SizedBox(width: 6),
                                Icon(Icons.keyboard_arrow_down_rounded, size: AppTypography.size(18)),
                              ],
                            ),
                          ),
                        );
                      }
                      return _ReviewRow(review: visibleReviews[index]);
                    },
                  ),
                ),
                if (place.mapsUrl != null) ...[
                  const Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _openGoogleMaps(place.mapsUrl!),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.open_in_new_rounded, size: AppTypography.size(15), color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.get('homeSeeAllOnGoogle'),
                              style: AppTypography.body(13.5, color: AppColors.primary, weight: FontWeight.w800, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ReviewRow extends StatelessWidget {
  final GoogleReviewSnippet review;
  const _ReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.premiumAccent,
          backgroundImage: review.authorPhoto != null
              ? ResizeImage(
                  NetworkImage(review.authorPhoto!),
                  width: (40 * MediaQuery.devicePixelRatioOf(context)).round(),
                )
              : null,
          child: review.authorPhoto == null
              ? Text(
                  review.author.isNotEmpty ? review.author[0].toUpperCase() : '?',
                  style: AppTypography.body(14, color: AppColors.primary, weight: FontWeight.w800),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.author,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(13.5, color: AppColors.textDark, weight: FontWeight.w800, height: 1.3),
                    ),
                  ),
                  if (review.relativeTime.isNotEmpty)
                    Text(review.relativeTime, style: AppTypography.body(12, color: AppColors.muted, height: 1.3)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  review.rating,
                  (i) => Icon(Icons.star_rounded, size: AppTypography.size(14), color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                review.text,
                style: AppTypography.body(13.5, color: AppColors.textDark, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
