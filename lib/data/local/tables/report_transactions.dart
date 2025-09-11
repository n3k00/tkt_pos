import 'package:drift/drift.dart';
import 'drivers.dart';
import 'transactions.dart';

class ReportTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Foreign keys
  IntColumn get driverId => integer().references(Drivers, #id)();
  IntColumn get transactionId => integer().references(Transactions, #id)();

  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
