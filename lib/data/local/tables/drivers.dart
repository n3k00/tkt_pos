import 'package:drift/drift.dart';

// Drivers table based on diagram
class Drivers extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Only the date component is relevant; store as DateTime
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text()();
}

