import 'package:get/get.dart';
import 'package:tkt_pos/features/home/presentation/bindings/home_binding.dart';
import 'package:tkt_pos/features/home/presentation/pages/home_page.dart';
import 'package:tkt_pos/features/inventory/presentation/bindings/inventory_binding.dart';
import 'package:tkt_pos/features/inventory/presentation/pages/inventory_page.dart';

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
  ];
}
