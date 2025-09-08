import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool compactTable = false.obs;

  void setCompactTable(bool v) => compactTable.value = v;
}

