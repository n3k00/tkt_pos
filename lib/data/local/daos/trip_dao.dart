import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/trip_main.dart';
import '../tables/trip_manifests.dart';

part 'trip_dao.g.dart';

@DriftAccessor(tables: [TripMains, TripManifests])
class TripDao extends DatabaseAccessor<AppDatabase> with _$TripDaoMixin {
  TripDao(super.db);

  Future<List<TripMain>> getTripMains() {
    return (select(tripMains)
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<int> insertTripMain({
    required DateTime date,
    required String driverName,
    required String carId,
  }) async {
    return into(tripMains).insert(TripMainsCompanion.insert(
      date: date.millisecondsSinceEpoch,
      driverName: driverName,
      carId: carId,
      commission: const Value.absent(),
      laborCost: const Value.absent(),
      supportPayment: const Value.absent(),
      roomFee: const Value.absent(),
      createdAt: const Value.absent(),
      updatedAt: const Value.absent(),
    ));
  }

  Future<List<TripManifest>> getManifestsByDriver(int driverId) {
    return (select(tripManifests)..where((t) => t.driverId.equals(driverId)))
        .get();
  }
}

