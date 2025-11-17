import 'package:intl/intl.dart';

class TimeUtils {
  // Restaurant operating hours (Spain time - CET/CEST)
  static const Map<int, Map<String, String>> operatingHours = {
    DateTime.monday: {'open': '12:00', 'close': '23:00'},
    DateTime.tuesday: {'open': '12:00', 'close': '23:00'},
    DateTime.wednesday: {'open': '12:00', 'close': '23:00'},
    DateTime.thursday: {'open': '12:00', 'close': '23:00'},
    DateTime.friday: {'open': '12:00', 'close': '24:00'}, // 12 AM next day
    DateTime.saturday: {'open': '12:00', 'close': '24:00'}, // 12 AM next day
    DateTime.sunday: {'open': '12:00', 'close': '23:00'},
  };

  /// Gets current time in Spain timezone (CET/CEST)
  static DateTime getSpainTime() {
    // Get UTC time and convert to Spain time (UTC+1 or UTC+2 during DST)
    final now = DateTime.now().toUtc();
    
    // Spain uses CET (UTC+1) and CEST (UTC+2 during daylight saving)
    // Daylight saving: Last Sunday of March to last Sunday of October
    final isDST = _isDaylightSavingTime(now);
    final offset = isDST ? 2 : 1;
    
    return now.add(Duration(hours: offset));
  }

  /// Check if given date is in daylight saving time for Europe
  static bool _isDaylightSavingTime(DateTime date) {
    final year = date.year;
    
    // Last Sunday of March
    final marchLastSunday = _getLastSundayOfMonth(year, 3);
    // Last Sunday of October
    final octoberLastSunday = _getLastSundayOfMonth(year, 10);
    
    return date.isAfter(marchLastSunday) && date.isBefore(octoberLastSunday);
  }

  static DateTime _getLastSundayOfMonth(int year, int month) {
    // Get last day of month
    final lastDay = DateTime(year, month + 1, 0);
    
    // Find last Sunday
    final daysToSubtract = (lastDay.weekday == DateTime.sunday) ? 0 : lastDay.weekday;
    return DateTime(year, month, lastDay.day - daysToSubtract, 2, 0, 0); // 2 AM transition
  }

  /// Check if restaurant is currently open
  static bool isRestaurantOpen() {
    final spainTime = getSpainTime();
    final dayOfWeek = spainTime.weekday;
    
    final hours = operatingHours[dayOfWeek];
    if (hours == null) return false;
    
    final openTime = _parseTime(hours['open']!);
    final closeTime = _parseTime(hours['close']!);
    
    final currentMinutes = spainTime.hour * 60 + spainTime.minute;
    final openMinutes = openTime['hour']! * 60 + openTime['minute']!;
    final closeMinutes = closeTime['hour']! * 60 + closeTime['minute']!;
    
    // Handle midnight closing (24:00 = 1440 minutes)
    if (closeMinutes == 1440) {
      // Open if between opening time and midnight
      return currentMinutes >= openMinutes;
    }
    
    return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
  }

  /// Get opening hours for current day
  static Map<String, String>? getTodayHours() {
    final spainTime = getSpainTime();
    return operatingHours[spainTime.weekday];
  }

  /// Get next opening time
  static DateTime? getNextOpeningTime() {
    final spainTime = getSpainTime();
    
    // Check today first
    final todayHours = operatingHours[spainTime.weekday];
    if (todayHours != null) {
      final openTime = _parseTime(todayHours['open']!);
      final todayOpening = DateTime(
        spainTime.year,
        spainTime.month,
        spainTime.day,
        openTime['hour']!,
        openTime['minute']!,
      );
      
      if (spainTime.isBefore(todayOpening)) {
        return todayOpening;
      }
    }
    
    // Check next 7 days
    for (int i = 1; i <= 7; i++) {
      final nextDay = spainTime.add(Duration(days: i));
      final nextDayHours = operatingHours[nextDay.weekday];
      
      if (nextDayHours != null) {
        final openTime = _parseTime(nextDayHours['open']!);
        return DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          openTime['hour']!,
          openTime['minute']!,
        );
      }
    }
    
    return null;
  }

  /// Get formatted closing time for today
  static String? getClosingTimeText() {
    final hours = getTodayHours();
    if (hours == null) return null;
    
    final closeTime = hours['close']!;
    if (closeTime == '24:00') return '12:00 AM';
    
    return _formatTime(closeTime);
  }

  /// Get time remaining until closing
  static String? getTimeUntilClosing() {
    if (!isRestaurantOpen()) return null;
    
    final spainTime = getSpainTime();
    final hours = getTodayHours();
    if (hours == null) return null;
    
    final closeTime = _parseTime(hours['close']!);
    final closingDateTime = DateTime(
      spainTime.year,
      spainTime.month,
      spainTime.day,
      closeTime['hour']! == 24 ? 23 : closeTime['hour']!,
      closeTime['hour']! == 24 ? 59 : closeTime['minute']!,
    );
    
    final difference = closingDateTime.difference(spainTime);
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  static Map<String, int> _parseTime(String time) {
    final parts = time.split(':');
    return {
      'hour': int.parse(parts[0]),
      'minute': int.parse(parts[1]),
    };
  }

  static String _formatTime(String time) {
    final parts = _parseTime(time);
    final hour = parts['hour']!;
    final minute = parts['minute']!;
    
    if (hour >= 12) {
      final displayHour = hour == 12 ? 12 : hour - 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} PM';
    } else {
      return '$hour:${minute.toString().padLeft(2, '0')} AM';
    }
  }
}