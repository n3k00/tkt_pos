import 'package:drift/drift.dart';

@DataClassName('TripMain')
class TripMains extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Store as epoch milliseconds to match existing data
  IntColumn get date => integer()();

  TextColumn get driverName => text().named('driver_name')();
  TextColumn get carId => text().named('car_id')();

  RealColumn get commission => real().nullable()();
  RealColumn get laborCost => real().named('labor_cost').nullable()();
  RealColumn get supportPayment => real().named('support_payment').nullable()();
  RealColumn get roomFee => real().named('room_fee').nullable()();

  // Keep timestamps optional; not used by UI currently
  TextColumn get createdAt => text().named('created_at').nullable()();
  TextColumn get updatedAt => text().named('updated_at').nullable()();
}

