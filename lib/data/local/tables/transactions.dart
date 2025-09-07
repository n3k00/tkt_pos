import 'package:drift/drift.dart';
import 'drivers.dart';

// Transactions table with a foreign key to drivers
@DataClassName('DbTransaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get customerName => text().named('customer_name').nullable()();
  TextColumn get phone => text()();
  TextColumn get parcelType => text().named('parcel_type')();
  TextColumn get number => text()();

  // Monetary values stored as REAL (double)
  RealColumn get charges => real().withDefault(const Constant(0.0))();
  TextColumn get paymentStatus => text().named('payment_status')();
  RealColumn get cashAdvance =>
      real().named('cash_advance').withDefault(const Constant(0.0))();

  BoolColumn get pickedUp => boolean().named('picked_up').withDefault(const Constant(false))();

  TextColumn get comment => text().nullable()();

  // Foreign key to drivers.id
  IntColumn get driverId => integer().named('driver_id').references(Drivers, #id)();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();
}
