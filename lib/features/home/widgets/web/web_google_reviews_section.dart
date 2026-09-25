import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Saborly/core/constant/app_colors.dart';
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

enum _OpenState { open, closingSoon, closed }

/// Open/closed status for the branch cards, derived from the same schedule
/// ([TimeUtils], Spain time) that gates checkout — so the badge always agrees
/// with whether an order can actually be placed. Google's `open_now` isn't
/// used: it's missing for some listings and would be stale behind the
/// backend's 12h cache.
class _OpenStatus {
  final _OpenState state;

  /// e.g. "Closes 11:00 PM", "Opens tomorrow at 12:00 PM".
  final String detail;

  const _OpenStatus(this.state, this.detail);

  static const _closingSoonWindow = Duration(minutes: 60);

  factory _OpenStatus.now() {
    final untilClose = TimeUtils.durationUntilClosing();
    if (untilClose != null) {
      final closesAtMidnight = TimeUtils.getTodayHours()?['close'] == '24:00';
      return _OpenStatus(
        untilClose <= _closingSoonWindow ? _OpenState.closingSoon : _OpenState.open,
        closesAtMidnight ? 'Closes at midnight' : 'Closes ${TimeUtils.getClosingTimeText()}',
      );
    }

    final next = TimeUtils.getNextOpeningTime();
    if (next == null) return const _OpenStatus(_OpenState.closed, '');

    final spainNow = TimeUtils.getSpainTime();
    final daysAway = DateTime.utc(next.year, next.month, next.day)
        .difference(DateTime.utc(spainNow.year, spainNow.month, spainNow.day))
        .inDays;
    final day = switch (daysAway) {
      0 => 'today',
      1 => 'tomorrow',
      _ => DateFormat('EEEE').format(next),
    };
    return _OpenStatus(_OpenState.closed, 'Opens $day at ${DateFormat('h:mm a').format(next)}');
  }

  @override
  bool operator ==(Object other) => other is _OpenStatus && other.state == state && other.detail == detail;

  @override
  int get hashCode => Object.hash(state, detail);
}

/// "What people are saying on Google" — pulls live rating/review data for
/// each active branch through the backend proxy. Retries briefly, then fails
/// silently (renders nothing, [header] included) if the backend/API key
/// isn't available, so the page never shows a heading with no reviews.
class WebGoogleReviewsSection extends StatefulWidget {
  /// Shown above the cards, and hidden along with them when there's nothing
  /// to show.
  final Widget? header;

  const WebGoogleReviewsSection({super.key, this.header});

  @override
  State<WebGoogleReviewsSection> createState() => _WebGoogleReviewsSectionState();
}

class _WebGoogleReviewsSectionState extends State<WebGoogleReviewsSection> {
  static const _retryDelays = [Duration(seconds: 2), Duration(seconds: 5)];

  late final Future<List<GooglePlaceSummary>> _future;
  late final Timer _statusTimer;
  _OpenStatus _status = _OpenStatus.now();

  @override
  void initState() {
    super.initState();
    _future = _loadPlaces();
    // Re-evaluate so the badge flips at opening/closing time without a reload.
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final next = _OpenStatus.now();
      if (next != _status) setState(() => _status = next);
    });
  }

  /// An empty result means the request failed (timeout, rate limit, Google
  /// lookup error) — every active branch has a listing — so retry a couple
  /// of times before giving up.
  Future<List<GooglePlaceSummary>> _loadPlaces() async {
    var raw = await ApiService().fetchGoogleReviews();
    for (final delay in _retryDelays) {
      if (raw.isNotEmpty || !mounted) break;
      await Future.delayed(delay);
      raw = await ApiService().fetchGoogleReviews();
    }
    return raw.map(GooglePlaceSummary.fromJson).toList();
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
          final cardWidth = columns == 1 ? constraints.maxWidth : (constraints.maxWidth - 20.w) / 2;

          return Wrap(
            spacing: 20.w,
            runSpacing: 20.h,
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

    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.premiumAccent, borderRadius: BorderRadius.circular(14.r)),
                child: Icon(Icons.storefront_rounded, size: 22.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: GoogleFonts.manrope(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13.sp, color: AppColors.muted),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            place.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(fontSize: 12.sp, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _openBadge(),
            ],
          ),
          SizedBox(height: 14.h),

          Wrap(
            spacing: 10.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (place.rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 16.sp, color: AppColors.secondary),
                    SizedBox(width: 4.w),
                    Text('${place.rating!.toStringAsFixed(1)}', style: GoogleFonts.manrope(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    SizedBox(width: 4.w),
                    Text('(${place.reviewCount})', style: GoogleFonts.manrope(fontSize: 12.5.sp, color: AppColors.muted)),
                  ],
                ),
              if (place.priceRange != null)
                Text(place.priceRange!, style: GoogleFonts.manrope(fontSize: 12.5.sp, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 140.w),
                child: Text(
                  place.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 12.5.sp, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ),
              if (status.detail.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 14.sp, color: AppColors.muted),
                    SizedBox(width: 4.w),
                    Text(status.detail, style: GoogleFonts.manrope(fontSize: 12.5.sp, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
            ],
          ),

          if (quote != null) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: AppColors.premiumAccent, borderRadius: BorderRadius.circular(14.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      quote.rating,
                      (i) => Icon(Icons.star_rounded, size: 13.sp, color: AppColors.secondary),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '"${quote.text}"',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(fontSize: 13.sp, color: AppColors.textDark, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                  SizedBox(height: 6.h),
                  Text('— ${quote.author}', style: GoogleFonts.manrope(fontSize: 11.5.sp, color: AppColors.muted, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],

          if (place.reviews.length > 1) ...[
            SizedBox(height: 12.h),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showAllReviews(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See some reviews',
                      style: GoogleFonts.manrope(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_rounded, size: 14.sp, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllReviews(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AllReviewsDialog(place: place),
    );
  }

  Widget _openBadge() {
    final (label, color) = switch (status.state) {
      _OpenState.open => ('Open now', AppColors.accentLeaf),
      _OpenState.closingSoon => ('Closing soon', AppColors.warning),
      _OpenState.closed => ('Closed', AppColors.error),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

/// Full review list for one place, opened from "See all N reviews". Sorted
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
          constraints: BoxConstraints(maxWidth: 560.w, maxHeight: 640.h),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 22.h, 16.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place.name, style: GoogleFonts.manrope(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                if (place.rating != null) ...[
                                  Icon(Icons.star_rounded, size: 15.sp, color: AppColors.secondary),
                                  SizedBox(width: 3.w),
                                  Text('${place.rating!.toStringAsFixed(1)}', style: GoogleFonts.manrope(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                  SizedBox(width: 6.w),
                                ],
                                Text('${place.reviewCount} Google reviews', style: GoogleFonts.manrope(fontSize: 12.5.sp, color: AppColors.muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.w),
                    shrinkWrap: true,
                    itemCount: visibleReviews.length + (hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
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
                                Text('Load more', style: GoogleFonts.manrope(fontSize: 13.5.sp, fontWeight: FontWeight.w800)),
                                SizedBox(width: 6.w),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp),
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
                  Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _openGoogleMaps(place.mapsUrl!),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 15.sp, color: AppColors.primary),
                            SizedBox(width: 8.w),
                            Text(
                              'See all reviews on Google',
                              style: GoogleFonts.manrope(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
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
          radius: 20.r,
          backgroundColor: AppColors.premiumAccent,
          backgroundImage: review.authorPhoto != null
              ? ResizeImage(
                  NetworkImage(review.authorPhoto!),
                  width: (40.r * MediaQuery.of(context).devicePixelRatio).round(),
                )
              : null,
          child: review.authorPhoto == null
              ? Text(
                  review.author.isNotEmpty ? review.author[0].toUpperCase() : '?',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.primary),
                )
              : null,
        ),
        SizedBox(width: 14.w),
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
                      style: GoogleFonts.manrope(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                  ),
                  if (review.relativeTime.isNotEmpty)
                    Text(review.relativeTime, style: GoogleFonts.manrope(fontSize: 11.5.sp, color: AppColors.muted)),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: List.generate(
                  review.rating,
                  (i) => Icon(Icons.star_rounded, size: 14.sp, color: AppColors.secondary),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                review.text,
                style: GoogleFonts.manrope(fontSize: 13.5.sp, color: AppColors.textDark, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
