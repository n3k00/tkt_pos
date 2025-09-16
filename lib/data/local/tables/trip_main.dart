import 'package:drift/drift.dart';

// Typed definition (not yet wired into @DriftDatabase)
class TripMain extends Table {
  @override
  String get tableName => 'trip_main';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get driverName => text().named('driver_name')();
  TextColumn get carId => text().named('car_id')();

  RealColumn get commission => real().nullable()();
  RealColumn get laborCost => real().named('labor_cost').nullable()();
  RealColumn get supportPayment => real().named('support_payment').nullable()();
  RealColumn get roomFee => real().named('room_fee').nullable()();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}
