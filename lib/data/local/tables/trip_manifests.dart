import 'package:drift/drift.dart';

// Typed definition (not yet wired into @DriftDatabase)
class TripManifests extends Table {
  @override
  String get tableName => 'trip_manifests';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get driverId => integer().named('driver_id')();

  TextColumn get customerName => text().named('customer_name').nullable()();
  TextColumn get deliveryCity => text().named('delivery_city').nullable()();
  TextColumn get phone => text().nullable()();

  TextColumn get parcelType => text().named('parcel_type')();
  IntColumn get numberOfParcel => integer().named('number_of_parcel')();

  RealColumn get cashAdvance => real().named('cash_advance').nullable()();
  RealColumn get paymentPending => real().named('payment_pending').nullable()();
  RealColumn get paymentPaid => real().named('payment_paid').nullable()();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}

