import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';

class HomeController extends GetxController {
  final AppDatabase db = AppDatabase();

  // State
  final RxString searchQuery = ''.obs;
  final RxList<TripMainRow> items = <TripMainRow>[].obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadTripMain();
  }

  // Actions
  void setSearch(String q) => searchQuery.value = q;

  Future<void> loadTripMain() async {
    final list = await db.getTripMainRows();
    items.assignAll(list);
  }

  Future<void> addTripMain({
    required DateTime date,
    required String driverName,
    required String carId,
  }) async {
    await db.insertTripMain(date: date, driverName: driverName, carId: carId);
    await loadTripMain();
  }
}
