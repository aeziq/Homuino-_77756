import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extensions for [BuildContext]
extension ContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Show a snackbar
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// Push to a new screen
  Future<T?> push<T>(Widget screen) => Navigator.push<T>(
    this,
    MaterialPageRoute(builder: (_) => screen),
  );

  /// Push and replace current screen
  Future<T?> pushReplacement<T>(Widget screen) => Navigator.pushReplacement<T, T>(
    this,
    MaterialPageRoute(builder: (_) => screen),
  );

  /// Pop the current screen
  void pop<T>([T? result]) => Navigator.pop<T>(this, result);
}

/// Extensions for [String]
extension StringExtensions on String {
  /// Capitalize first letter of string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Format string as date
  String formatDate({String pattern = 'MMM dd, yyyy'}) {
    try {
      final date = DateTime.parse(this);
      return DateFormat(pattern).format(date);
    } catch (e) {
      return this;
    }
  }

  /// Check if string is a valid email
  bool get isEmail => RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  ).hasMatch(this);

  /// Check if string is a valid URL
  bool get isUrl => RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  ).hasMatch(this);

  /// Convert string to [Color]
  Color toColor() {
    var hexString = this;
    if (hexString.startsWith('#')) {
      hexString = hexString.substring(1);
    }
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }
    return Color(int.parse(hexString, radix: 16));
  }
}

/// Extensions for [DateTime]
extension DateTimeExtensions on DateTime {
  /// Format date as string
  String format({String pattern = 'MMM dd, yyyy'}) =>
      DateFormat(pattern).format(this);

  /// Get time ago string
  String timeAgo({bool numericDates = true}) {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return numericDates ? '$years year${years == 1 ? '' : 's'} ago' : 'Last year';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return numericDates ? '$months month${months == 1 ? '' : 's'} ago' : 'Last month';
    } else if (difference.inDays > 0) {
      return numericDates ? '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago' : 'Yesterday';
    } else if (difference.inHours > 0) {
      return numericDates ? '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago' : 'Today';
    } else if (difference.inMinutes > 0) {
      return numericDates ? '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago' : 'Just now';
    } else {
      return 'Just now';
    }
  }
}

/// Extensions for [List]
extension ListExtensions<T> on List<T> {
  /// Add item if not already in list
  List<T> addIfNotContains(T item) {
    if (!contains(item)) {
      add(item);
    }
    return this;
  }

  /// Insert item between each existing item
  List<T> insertBetween(T separator) {
    if (length <= 1) return this;
    final newList = <T>[];
    for (var i = 0; i < length; i++) {
      newList.add(this[i]);
      if (i != length - 1) {
        newList.add(separator);
      }
    }
    return newList;
  }
}

/// Extensions for [Color]
extension ColorExtensions on Color {
  /// Darken color by [percent]
  Color darken([double percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }

  /// Lighten color by [percent]
  Color lighten([double percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }

  /// Convert color to hex string
  String toHex() => '#${value.toRadixString(16).substring(2)}';
}

/// Extensions for [Iterable]
extension IterableExtensions<T> on Iterable<T> {
  /// Map with index
  Iterable<E> mapIndexed<E>(E Function(int index, T item) f) sync* {
    var index = 0;
    for (final item in this) {
      yield f(index, item);
      index++;
    }
  }
}

/// Extensions for [Widget]
extension WidgetExtensions on Widget {
  /// Add padding to widget
  Widget paddingAll(double padding) => Padding(
    padding: EdgeInsets.all(padding),
    child: this,
  );

  /// Add symmetric padding to widget
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Add padding only to widget
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  /// Center widget
  Widget center() => Center(child: this);

  /// Add tap gesture to widget
  Widget onTap(VoidCallback onTap, {bool opaque = true}) => GestureDetector(
    behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
    onTap: onTap,
    child: this,
  );
}