import 'package:drift/drift.dart';
import 'transactions.dart';
import 'drivers.dart';

@DataClassName('TransactionEditHistoryEntry')
class TransactionEditHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Metadata for grouping edit snapshots
  IntColumn get editId => integer().named('edit_id')();
  BoolColumn get isBefore =>
      boolean().named('is_before').withDefault(const Constant(false))();
  DateTimeColumn get editTime =>
      dateTime().named('edit_time').withDefault(currentDateAndTime)();
  BoolColumn get isDeletion =>
      boolean().named('is_deletion').withDefault(const Constant(false))();

  IntColumn get transactionId =>
      integer().named('transaction_id').references(Transactions, #id)();

  // Snapshot of transaction fields
  TextColumn get customerName =>
      text().named('customer_name').nullable()();
  TextColumn get phone => text()();
  TextColumn get parcelType => text().named('parcel_type')();
  TextColumn get number => text()();
  RealColumn get charges =>
      real().withDefault(const Constant(0.0))();
  TextColumn get paymentStatus =>
      text().named('payment_status')();
  RealColumn get cashAdvance =>
      real().named('cash_advance').withDefault(const Constant(0.0))();
  BoolColumn get pickedUp => boolean()
      .named('picked_up')
      .withDefault(const Constant(false))();
  TextColumn get comment => text().nullable()();
  IntColumn get driverId =>
      integer().named('driver_id').references(Drivers, #id)();
  DateTimeColumn get createdAt => dateTime()
      .named('created_at')
      .withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()
      .named('updated_at')
      .withDefault(currentDateAndTime)();
}
