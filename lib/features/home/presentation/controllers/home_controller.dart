import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/trips/data/trip_repository.dart';
import 'package:tkt_pos/utils/format.dart';

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

  List<TripMain> get filteredItems {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return items.toList(growable: false);
    return items
        .where((item) {
          final fields = <String>[
            item.driverName,
            item.carId,
            Format.date(DateTime.fromMillisecondsSinceEpoch(item.date)),
            (item.commission ?? 0).toString(),
            (item.laborCost ?? 0).toString(),
            (item.supportPayment ?? 0).toString(),
            (item.roomFee ?? 0).toString(),
          ];
          return fields.any((field) => field.toLowerCase().contains(q));
        })
        .toList(growable: false);
  }

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
