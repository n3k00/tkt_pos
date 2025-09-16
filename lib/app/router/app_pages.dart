import 'package:get/get.dart';
import 'package:tkt_pos/features/home/presentation/bindings/home_binding.dart';
import 'package:tkt_pos/features/home/presentation/pages/home_page.dart';
import 'package:tkt_pos/features/inventory/presentation/bindings/inventory_binding.dart';
import 'package:tkt_pos/features/inventory/presentation/pages/inventory_page.dart';
import 'package:tkt_pos/features/settings/presentation/bindings/settings_binding.dart';
import 'package:tkt_pos/features/settings/presentation/pages/settings_page.dart';
import 'package:tkt_pos/features/reports/presentation/bindings/reports_binding.dart';
import 'package:tkt_pos/features/reports/presentation/pages/reports_page.dart';
import 'package:tkt_pos/features/trips/presentation/pages/trip_detail_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const InventoryPage(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.reports,
      page: () => const ReportsPage(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: Routes.tripDetail,
      page: () => const TripDetailPage(),
    ),
  ];
}
