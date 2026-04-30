import 'package:drift/drift.dart';

class DriverProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}
