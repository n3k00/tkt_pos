import 'package:get/get.dart';

class ReportsController extends GetxController {
  final RxInt currentTabIndex = 0.obs;

  void setTab(int index) {
    currentTabIndex.value = index;
  }
}

