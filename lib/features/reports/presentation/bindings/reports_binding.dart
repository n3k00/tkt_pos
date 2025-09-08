import 'package:get/get.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsController>(() => ReportsController());
  }
}

