import 'package:drift/drift.dart';
import 'drivers.dart';

class DriverPayoutHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get driverId =>
      integer().named('driver_id').references(Drivers, #id)();
  TextColumn get action => text()();
  BoolColumn get previousPaidOut => boolean().named('previous_paid_out')();
  BoolColumn get newPaidOut => boolean().named('new_paid_out')();
  RealColumn get previousPaidOutAmount =>
      real().named('previous_paid_out_amount').nullable()();
  RealColumn get newPaidOutAmount =>
      real().named('new_paid_out_amount').nullable()();
  DateTimeColumn get previousPaidOutAt =>
      dateTime().named('previous_paid_out_at').nullable()();
  DateTimeColumn get newPaidOutAt =>
      dateTime().named('new_paid_out_at').nullable()();
  DateTimeColumn get changedAt =>
      dateTime().named('changed_at').withDefault(currentDateAndTime)();
}
