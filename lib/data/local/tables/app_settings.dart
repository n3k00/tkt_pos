import 'package:drift/drift.dart';

// Example table for simple key-value app settings
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

