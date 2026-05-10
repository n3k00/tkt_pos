import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:tkt_pos/data/local/app_database.dart';

void main() {
  test('migration adds payout and driver profile schema from v13', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
CREATE TABLE drivers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date INTEGER NOT NULL,
  name TEXT NOT NULL
);

INSERT INTO drivers (date, name) VALUES (1767225600000, 'Driver One');

PRAGMA user_version = 13;
''');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final drivers = await db.select(db.drivers).get();
    final driverColumns = await _columnNames(db, 'drivers');

    expect(drivers, hasLength(1));
    expect(driverColumns, containsAll(_expectedDriverColumns));
    expect(await _tableExists(db, 'driver_profiles'), isTrue);
    expect(await _tableExists(db, 'driver_payout_history'), isTrue);

    final profiles = await db.select(db.driverProfiles).get();
    expect(profiles, hasLength(1));
    expect(profiles.single.name, 'Driver One');
    expect(profiles.single.active, isTrue);
    expect(drivers.single.profileId, profiles.single.id);
    expect(drivers.single.paidOut, isFalse);
    expect(drivers.single.paidOutAmount, isNull);
    expect(drivers.single.paidOutAt, isNull);
  });

  test('migration dedupes driver profiles and adds normalized unique index', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute('''
CREATE TABLE driver_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE drivers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER,
  date INTEGER NOT NULL,
  name TEXT NOT NULL,
  room_fee REAL,
  labor_fee REAL,
  delivery_fee REAL,
  paid_out INTEGER NOT NULL DEFAULT 0,
  paid_out_amount REAL,
  paid_out_at INTEGER
);

INSERT INTO driver_profiles (id, name, phone, active) VALUES
  (1, 'Ko Aung', '111', 1),
  (2, ' ko aung ', '222', 1),
  (3, 'Ma Su', '333', 1);

INSERT INTO drivers (id, profile_id, date, name, paid_out)
VALUES
  (1, 2, 1767225600000, 'Ko Aung', 0),
  (2, 3, 1767225600000, 'Ma Su', 0);

PRAGMA user_version = 18;
''');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final profiles = await db.select(db.driverProfiles).get();
    final drivers = await db.select(db.drivers).get();

    expect(
      profiles.map((profile) => profile.name).toList(),
      containsAll(['Ko Aung', 'Ma Su']),
    );
    expect(
      profiles.where((profile) => profile.name.trim().toLowerCase() == 'ko aung'),
      hasLength(1),
    );
    expect(
      drivers.firstWhere((driver) => driver.id == 1).profileId,
      profiles.firstWhere((profile) => profile.name == 'Ko Aung').id,
    );

    expect(
      () => raw.execute(
        "INSERT INTO driver_profiles (name, phone, active) VALUES ('KO AUNG', '999', 1)",
      ),
      throwsA(isA<sqlite.SqliteException>()),
    );
  });
}

const _expectedDriverColumns = [
  'profile_id',
  'room_fee',
  'labor_fee',
  'delivery_fee',
  'paid_out',
  'paid_out_amount',
  'paid_out_at',
];

Future<List<String>> _columnNames(AppDatabase db, String tableName) async {
  final rows = await db.customSelect('PRAGMA table_info($tableName)').get();
  return [for (final row in rows) row.data['name'] as String];
}

Future<bool> _tableExists(AppDatabase db, String tableName) async {
  final rows = await db
      .customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          drift.Variable.withString('table'),
          drift.Variable.withString(tableName),
        ],
      )
      .get();
  return rows.isNotEmpty;
}
