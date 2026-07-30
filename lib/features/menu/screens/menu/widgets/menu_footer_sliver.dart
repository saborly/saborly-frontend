import 'package:flutter/material.dart';
import 'package:Saborly/shared/widgets/ooter.dart';

/// Extracted verbatim from `_MenuScreenState._buildFooterSliver`.
///
/// [isDesktop] is unused in the original implementation as well — kept as a
/// parameter to preserve the exact original signature/behavior.
class MenuFooterSliver extends StatelessWidget {
  final bool isDesktop;

  const MenuFooterSliver({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FoodKingFooter(),
    );
  }
}
