import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFD84E17);
  static const Color primaryLight = Color(0xFFFFC8A8);
  static const Color primaryDark = Color(0xFF8C2F12);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFF5A623);
  static const Color secondaryLight = Color(0xFFFFE2A8);
  static const Color secondaryDark = Color(0xFF9D5A13);

  // Brand Neutrals
  static const Color accentBerry = Color(0xFF6A1638);
  static const Color accentCream = Color(0xFFFFF4E8);
  static const Color accentSand = Color(0xFFF6E4CF);
  static const Color accentLeaf = Color(0xFF2F7A53);
  static const Color accentNight = Color(0xFF2A1611);
  
  // Background Colors
  static const Color background = Color(0xFFFBF3E7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFCF8);
  
  // Text Colors
  static const Color textDark = Color(0xFF28140E);
  static const Color textMedium = Color(0xFF72513E);
  static const Color textLight = Color(0xFFA08371);
  static const Color textHint = Color(0xFFC3AA97);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Food Category Colors
  static const Color friendsFamily = Color(0xFFFFE0B2);
  static const Color highOn = Color(0xFFE8F5E8);
  static const Color duetCombos = Color(0xFFFFF3E0);
  static const Color whopper = Color(0xFFE3F2FD);
  
  // Premium homepage tokens
  static const Color premiumAccent = Color(0xFFFFF7F2);
  static const Color muted = Color(0xFF6B7280);

  // Additional Colors
  static const Color border = Color(0xFFE7D3BD);
  static const Color divider = Color(0xFFF0E1D2);
  static const Color shadow = Color(0x291A0803);
  static const Color shimmer = Color(0xFFF0DFCF);
  static const Color shimmerHighlight = Color(0xFFFFF8F1);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE46221), Color(0xFFB33E17)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4F1F14), Color(0xFF7B2F17), Color(0xFFD84E17)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFF9F1), Color(0xFFFFF0E1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Food Item Colors
  static const Map<String, Color> foodCategoryColors = {
    'burger': Color(0xFFFFE0B2),
    'pizza': Color(0xFFE8F5E8),
    'chicken': Color(0xFFFFF3E0),
    'drinks': Color(0xFFE3F2FD),
    'dessert': Color(0xFFF3E5F5),
    'combo': Color(0xFFE0F2F1),
  };
  
  // Order Status Colors
  static const Map<String, Color> orderStatusColors = {
    'pending': Color(0xFFFF9800),
    'confirmed': Color(0xFF2196F3),
    'preparing': Color(0xFFFF5722),
    'ready': Color(0xFF9C27B0),
    'delivered': Color(0xFF4CAF50),
    'cancelled': Color(0xFFF44336),
  };
}
