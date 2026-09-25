import 'package:Saborly/core/constant/app_strings.dart';

/// Category chip shown on each video card and in the viewer.
enum SaborlyVideoTag {
  menu('videoTagMenu'),
  review('videoTagReview'),
  event('videoTagEvent'),
  guest('videoTagGuest'),
  experience('videoTagExperience');

  const SaborlyVideoTag(this.labelKey);

  final String labelKey;

  String get label => AppStrings.get(labelKey);
}

/// A brand video bundled with the app.
///
/// Files in assets/videos/optimized are re-encoded copies of the originals in
/// assets/videos (H.264/AAC, max 720p, moov atom first so the web can start
/// playing before the whole file downloads). Each has a matching poster frame
/// in assets/videos/posters, so cards render instantly without decoding video.
class SaborlyVideo {
  final String id;
  final String titleKey;
  final SaborlyVideoTag tag;

  /// Known up front so cards can show it before any video is loaded.
  final Duration duration;

  const SaborlyVideo({
    required this.id,
    required this.titleKey,
    required this.tag,
    required this.duration,
  });

  String get videoAsset => 'assets/videos/optimized/saborly_$id.mp4';
  String get posterAsset => 'assets/videos/posters/saborly_$id.jpg';
  String get title => AppStrings.get(titleKey);
}

/// "0:33", "3:17"
String formatVideoDuration(Duration d) {
  final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '${d.inMinutes}:$seconds';
}

/// Display order: strongest food visuals first to hook the scroll.
const List<SaborlyVideo> saborlyVideos = [
  SaborlyVideo(
    id: 'taste_of_pakistan',
    titleKey: 'videoTitleTasteOfPakistan',
    tag: SaborlyVideoTag.menu,
    duration: Duration(seconds: 11),
  ),
  SaborlyVideo(
    id: 'friends_and_family',
    titleKey: 'videoTitleFriendsAndFamily',
    tag: SaborlyVideoTag.experience,
    duration: Duration(seconds: 33),
  ),
  SaborlyVideo(
    id: 'great_value',
    titleKey: 'videoTitleGreatValue',
    tag: SaborlyVideoTag.review,
    duration: Duration(seconds: 13),
  ),
  SaborlyVideo(
    id: 'nauman_ijaz_visit',
    titleKey: 'videoTitleNaumanIjazVisit',
    tag: SaborlyVideoTag.guest,
    duration: Duration(seconds: 23),
  ),
  SaborlyVideo(
    id: 'sabadell_fair',
    titleKey: 'videoTitleSabadellFair',
    tag: SaborlyVideoTag.event,
    duration: Duration(seconds: 13),
  ),
  SaborlyVideo(
    id: 'food_review',
    titleKey: 'videoTitleFoodReview',
    tag: SaborlyVideoTag.review,
    duration: Duration(seconds: 197),
  ),
  SaborlyVideo(
    id: 'family_moments',
    titleKey: 'videoTitleFamilyMoments',
    tag: SaborlyVideoTag.review,
    duration: Duration(seconds: 42),
  ),
  SaborlyVideo(
    id: 'burger_or_pizza',
    titleKey: 'videoTitleBurgerOrPizza',
    tag: SaborlyVideoTag.menu,
    duration: Duration(seconds: 29),
  ),
  SaborlyVideo(
    id: 'chicken_tacos',
    titleKey: 'videoTitleChickenTacos',
    tag: SaborlyVideoTag.menu,
    duration: Duration(seconds: 10),
  ),
  SaborlyVideo(
    id: 'orange_blue_mocktail',
    titleKey: 'videoTitleOrangeBlueMocktail',
    tag: SaborlyVideoTag.menu,
    duration: Duration(seconds: 11),
  ),
  SaborlyVideo(
    id: 'come_eat_now',
    titleKey: 'videoTitleComeEatNow',
    tag: SaborlyVideoTag.menu,
    duration: Duration(seconds: 19),
  ),
  SaborlyVideo(
    id: 'red_velvet_cake',
    titleKey: 'videoTitleRedVelvetCake',
    tag: SaborlyVideoTag.menu,
    duration: Duration(seconds: 5),
  ),
];
