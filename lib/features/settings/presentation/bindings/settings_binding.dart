import 'package:get/get.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}

