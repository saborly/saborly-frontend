import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import '../../../../../shared/models/food_item.dart';

class FoodImageSection extends StatelessWidget {
  final FoodItem foodItem;

  const FoodImageSection({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Hero(
        tag: 'food_${foodItem.id}',
        child: kIsWeb
            ? Image.network(
                foodItem.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 80.sp,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: foodItem.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 80.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ),
      ),
    );
  }
}
