import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/data/local/tables/trip_main.dart';
import 'package:tkt_pos/data/local/tables/trip_manifests.dart';

class TripRepository {
  TripRepository._internal();
  static final TripRepository _instance = TripRepository._internal();
  factory TripRepository() => _instance;

  final AppDatabase _db = AppDatabase();

  Future<List<TripMain>> getTripMains() {
    return _db.tripDao.getTripMains();
  }

  Future<int> addTripMain({
    required DateTime date,
    required String driverName,
    required String carId,
  }) {
    return _db.tripDao.insertTripMain(
      date: date,
      driverName: driverName,
      carId: carId,
    );
  }

  Future<List<TripManifest>> getTripManifests(int driverId) {
    return _db.tripDao.getManifestsByDriver(driverId);
  }
}

