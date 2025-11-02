import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/trips/data/trip_repository.dart';

class HomeController extends GetxController {
  final AppDatabase db = AppDatabase();
  final TripRepository tripRepo = TripRepository();

  // State
  final RxString searchQuery = ''.obs;
  final RxList<TripMain> items = <TripMain>[].obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadTripMain();
  }

  // Actions
  void setSearch(String q) => searchQuery.value = q;

  Future<void> loadTripMain() async {
    final list = await tripRepo.getTripMains();
    items.assignAll(list);
  }

  Future<void> addTripMain({
    required DateTime date,
    required String driverName,
    required String carId,
  }) async {
    await tripRepo.addTripMain(
      date: date,
      driverName: driverName,
      carId: carId,
    );
    await loadTripMain();
  }
}
