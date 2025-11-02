import 'package:drift/drift.dart';
import 'trip_main.dart';

@DataClassName('TripManifest')
class TripManifests extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get driverId => integer().named('driver_id').references(TripMains, #id)();

  TextColumn get customerName => text().named('customer_name').nullable()();
  TextColumn get deliveryCity => text().named('delivery_city').nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get parcelType => text().named('parcel_type')();
  IntColumn get numberOfParcel => integer().named('number_of_parcel')();

  RealColumn get cashAdvance => real().named('cash_advance').nullable()();
  RealColumn get paymentPending => real().named('payment_pending').nullable()();
  RealColumn get paymentPaid => real().named('payment_paid').nullable()();

  // Optional raw timestamps (not currently used in UI)
  TextColumn get createdAt => text().named('created_at').nullable()();
  TextColumn get updatedAt => text().named('updated_at').nullable()();
}

