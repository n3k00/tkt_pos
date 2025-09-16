part of 'app_pages.dart';

abstract class Routes {
  static const String home = _Paths.home;
  static const String inventory = _Paths.inventory;
  static const String settings = _Paths.settings;
  static const String reports = _Paths.reports;
  static const String tripDetail = _Paths.tripDetail;
}

abstract class _Paths {
  static const String home = '/home';
  static const String inventory = '/inventory';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String tripDetail = '/trip-detail';
}
