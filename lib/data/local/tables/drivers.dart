import 'package:drift/drift.dart';
import 'driver_profiles.dart';

class Drivers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer()
      .named('profile_id')
      .nullable()
      .references(DriverProfiles, #id)();
  // Only the date component is relevant; store as DateTime
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text()();
  RealColumn get roomFee => real().named('room_fee').nullable()();
  RealColumn get laborFee => real().named('labor_fee').nullable()();
  RealColumn get deliveryFee => real().named('delivery_fee').nullable()();
  BoolColumn get paidOut =>
      boolean().named('paid_out').withDefault(const Constant(false))();
}
