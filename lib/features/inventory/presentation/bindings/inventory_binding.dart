import 'package:get/get.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryController>(() => InventoryController());
  }
}

