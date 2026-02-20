// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DriversTable extends Drivers with TableInfo<$DriversTable, Driver> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriversTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomFeeMeta = const VerificationMeta(
    'roomFee',
  );
  @override
  late final GeneratedColumn<double> roomFee = GeneratedColumn<double>(
    'room_fee',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _laborFeeMeta = const VerificationMeta(
    'laborFee',
  );
  @override
  late final GeneratedColumn<double> laborFee = GeneratedColumn<double>(
    'labor_fee',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryFeeMeta = const VerificationMeta(
    'deliveryFee',
  );
  @override
  late final GeneratedColumn<double> deliveryFee = GeneratedColumn<double>(
    'delivery_fee',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidOutMeta = const VerificationMeta(
    'paidOut',
  );
  @override
  late final GeneratedColumn<bool> paidOut = GeneratedColumn<bool>(
    'paid_out',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid_out" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    name,
    roomFee,
    laborFee,
    deliveryFee,
    paidOut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drivers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Driver> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('room_fee')) {
      context.handle(
        _roomFeeMeta,
        roomFee.isAcceptableOrUnknown(data['room_fee']!, _roomFeeMeta),
      );
    }
    if (data.containsKey('labor_fee')) {
      context.handle(
        _laborFeeMeta,
        laborFee.isAcceptableOrUnknown(data['labor_fee']!, _laborFeeMeta),
      );
    }
    if (data.containsKey('delivery_fee')) {
      context.handle(
        _deliveryFeeMeta,
        deliveryFee.isAcceptableOrUnknown(
          data['delivery_fee']!,
          _deliveryFeeMeta,
        ),
      );
    }
    if (data.containsKey('paid_out')) {
      context.handle(
        _paidOutMeta,
        paidOut.isAcceptableOrUnknown(data['paid_out']!, _paidOutMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Driver map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Driver(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      roomFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}room_fee'],
      ),
      laborFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}labor_fee'],
      ),
      deliveryFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delivery_fee'],
      ),
      paidOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid_out'],
      )!,
    );
  }

  @override
  $DriversTable createAlias(String alias) {
    return $DriversTable(attachedDatabase, alias);
  }
}

class Driver extends DataClass implements Insertable<Driver> {
  final int id;
  final DateTime date;
  final String name;
  final double? roomFee;
  final double? laborFee;
  final double? deliveryFee;
  final bool paidOut;
  const Driver({
    required this.id,
    required this.date,
    required this.name,
    this.roomFee,
    this.laborFee,
    this.deliveryFee,
    required this.paidOut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || roomFee != null) {
      map['room_fee'] = Variable<double>(roomFee);
    }
    if (!nullToAbsent || laborFee != null) {
      map['labor_fee'] = Variable<double>(laborFee);
    }
    if (!nullToAbsent || deliveryFee != null) {
      map['delivery_fee'] = Variable<double>(deliveryFee);
    }
    map['paid_out'] = Variable<bool>(paidOut);
    return map;
  }

  DriversCompanion toCompanion(bool nullToAbsent) {
    return DriversCompanion(
      id: Value(id),
      date: Value(date),
      name: Value(name),
      roomFee: roomFee == null && nullToAbsent
          ? const Value.absent()
          : Value(roomFee),
      laborFee: laborFee == null && nullToAbsent
          ? const Value.absent()
          : Value(laborFee),
      deliveryFee: deliveryFee == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryFee),
      paidOut: Value(paidOut),
    );
  }

  factory Driver.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Driver(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      name: serializer.fromJson<String>(json['name']),
      roomFee: serializer.fromJson<double?>(json['roomFee']),
      laborFee: serializer.fromJson<double?>(json['laborFee']),
      deliveryFee: serializer.fromJson<double?>(json['deliveryFee']),
      paidOut: serializer.fromJson<bool>(json['paidOut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'name': serializer.toJson<String>(name),
      'roomFee': serializer.toJson<double?>(roomFee),
      'laborFee': serializer.toJson<double?>(laborFee),
      'deliveryFee': serializer.toJson<double?>(deliveryFee),
      'paidOut': serializer.toJson<bool>(paidOut),
    };
  }

  Driver copyWith({
    int? id,
    DateTime? date,
    String? name,
    Value<double?> roomFee = const Value.absent(),
    Value<double?> laborFee = const Value.absent(),
    Value<double?> deliveryFee = const Value.absent(),
    bool? paidOut,
  }) => Driver(
    id: id ?? this.id,
    date: date ?? this.date,
    name: name ?? this.name,
    roomFee: roomFee.present ? roomFee.value : this.roomFee,
    laborFee: laborFee.present ? laborFee.value : this.laborFee,
    deliveryFee: deliveryFee.present ? deliveryFee.value : this.deliveryFee,
    paidOut: paidOut ?? this.paidOut,
  );
  Driver copyWithCompanion(DriversCompanion data) {
    return Driver(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      roomFee: data.roomFee.present ? data.roomFee.value : this.roomFee,
      laborFee: data.laborFee.present ? data.laborFee.value : this.laborFee,
      deliveryFee: data.deliveryFee.present
          ? data.deliveryFee.value
          : this.deliveryFee,
      paidOut: data.paidOut.present ? data.paidOut.value : this.paidOut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Driver(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('roomFee: $roomFee, ')
          ..write('laborFee: $laborFee, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('paidOut: $paidOut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, name, roomFee, laborFee, deliveryFee, paidOut);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Driver &&
          other.id == this.id &&
          other.date == this.date &&
          other.name == this.name &&
          other.roomFee == this.roomFee &&
          other.laborFee == this.laborFee &&
          other.deliveryFee == this.deliveryFee &&
          other.paidOut == this.paidOut);
}

class DriversCompanion extends UpdateCompanion<Driver> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> name;
  final Value<double?> roomFee;
  final Value<double?> laborFee;
  final Value<double?> deliveryFee;
  final Value<bool> paidOut;
  const DriversCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.roomFee = const Value.absent(),
    this.laborFee = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    this.paidOut = const Value.absent(),
  });
  DriversCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String name,
    this.roomFee = const Value.absent(),
    this.laborFee = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    this.paidOut = const Value.absent(),
  }) : date = Value(date),
       name = Value(name);
  static Insertable<Driver> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? name,
    Expression<double>? roomFee,
    Expression<double>? laborFee,
    Expression<double>? deliveryFee,
    Expression<bool>? paidOut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (roomFee != null) 'room_fee': roomFee,
      if (laborFee != null) 'labor_fee': laborFee,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (paidOut != null) 'paid_out': paidOut,
    });
  }

  DriversCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? name,
    Value<double?>? roomFee,
    Value<double?>? laborFee,
    Value<double?>? deliveryFee,
    Value<bool>? paidOut,
  }) {
    return DriversCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      roomFee: roomFee ?? this.roomFee,
      laborFee: laborFee ?? this.laborFee,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paidOut: paidOut ?? this.paidOut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (roomFee.present) {
      map['room_fee'] = Variable<double>(roomFee.value);
    }
    if (laborFee.present) {
      map['labor_fee'] = Variable<double>(laborFee.value);
    }
    if (deliveryFee.present) {
      map['delivery_fee'] = Variable<double>(deliveryFee.value);
    }
    if (paidOut.present) {
      map['paid_out'] = Variable<bool>(paidOut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriversCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('roomFee: $roomFee, ')
          ..write('laborFee: $laborFee, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('paidOut: $paidOut')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, DbTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelTypeMeta = const VerificationMeta(
    'parcelType',
  );
  @override
  late final GeneratedColumn<String> parcelType = GeneratedColumn<String>(
    'parcel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargesMeta = const VerificationMeta(
    'charges',
  );
  @override
  late final GeneratedColumn<double> charges = GeneratedColumn<double>(
    'charges',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashAdvanceMeta = const VerificationMeta(
    'cashAdvance',
  );
  @override
  late final GeneratedColumn<double> cashAdvance = GeneratedColumn<double>(
    'cash_advance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _pickedUpMeta = const VerificationMeta(
    'pickedUp',
  );
  @override
  late final GeneratedColumn<bool> pickedUp = GeneratedColumn<bool>(
    'picked_up',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("picked_up" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    phone,
    parcelType,
    number,
    charges,
    paymentStatus,
    cashAdvance,
    pickedUp,
    comment,
    driverId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('parcel_type')) {
      context.handle(
        _parcelTypeMeta,
        parcelType.isAcceptableOrUnknown(data['parcel_type']!, _parcelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelTypeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('charges')) {
      context.handle(
        _chargesMeta,
        charges.isAcceptableOrUnknown(data['charges']!, _chargesMeta),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('cash_advance')) {
      context.handle(
        _cashAdvanceMeta,
        cashAdvance.isAcceptableOrUnknown(
          data['cash_advance']!,
          _cashAdvanceMeta,
        ),
      );
    }
    if (data.containsKey('picked_up')) {
      context.handle(
        _pickedUpMeta,
        pickedUp.isAcceptableOrUnknown(data['picked_up']!, _pickedUpMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      parcelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_type'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      charges: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charges'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      cashAdvance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cash_advance'],
      )!,
      pickedUp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}picked_up'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driver_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class DbTransaction extends DataClass implements Insertable<DbTransaction> {
  final int id;
  final String? customerName;
  final String phone;
  final String parcelType;
  final String number;
  final double charges;
  final String paymentStatus;
  final double cashAdvance;
  final bool pickedUp;
  final String? comment;
  final int driverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbTransaction({
    required this.id,
    this.customerName,
    required this.phone,
    required this.parcelType,
    required this.number,
    required this.charges,
    required this.paymentStatus,
    required this.cashAdvance,
    required this.pickedUp,
    this.comment,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['phone'] = Variable<String>(phone);
    map['parcel_type'] = Variable<String>(parcelType);
    map['number'] = Variable<String>(number);
    map['charges'] = Variable<double>(charges);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['cash_advance'] = Variable<double>(cashAdvance);
    map['picked_up'] = Variable<bool>(pickedUp);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['driver_id'] = Variable<int>(driverId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      phone: Value(phone),
      parcelType: Value(parcelType),
      number: Value(number),
      charges: Value(charges),
      paymentStatus: Value(paymentStatus),
      cashAdvance: Value(cashAdvance),
      pickedUp: Value(pickedUp),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      driverId: Value(driverId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTransaction(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      phone: serializer.fromJson<String>(json['phone']),
      parcelType: serializer.fromJson<String>(json['parcelType']),
      number: serializer.fromJson<String>(json['number']),
      charges: serializer.fromJson<double>(json['charges']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      cashAdvance: serializer.fromJson<double>(json['cashAdvance']),
      pickedUp: serializer.fromJson<bool>(json['pickedUp']),
      comment: serializer.fromJson<String?>(json['comment']),
      driverId: serializer.fromJson<int>(json['driverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String?>(customerName),
      'phone': serializer.toJson<String>(phone),
      'parcelType': serializer.toJson<String>(parcelType),
      'number': serializer.toJson<String>(number),
      'charges': serializer.toJson<double>(charges),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'cashAdvance': serializer.toJson<double>(cashAdvance),
      'pickedUp': serializer.toJson<bool>(pickedUp),
      'comment': serializer.toJson<String?>(comment),
      'driverId': serializer.toJson<int>(driverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbTransaction copyWith({
    int? id,
    Value<String?> customerName = const Value.absent(),
    String? phone,
    String? parcelType,
    String? number,
    double? charges,
    String? paymentStatus,
    double? cashAdvance,
    bool? pickedUp,
    Value<String?> comment = const Value.absent(),
    int? driverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbTransaction(
    id: id ?? this.id,
    customerName: customerName.present ? customerName.value : this.customerName,
    phone: phone ?? this.phone,
    parcelType: parcelType ?? this.parcelType,
    number: number ?? this.number,
    charges: charges ?? this.charges,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    cashAdvance: cashAdvance ?? this.cashAdvance,
    pickedUp: pickedUp ?? this.pickedUp,
    comment: comment.present ? comment.value : this.comment,
    driverId: driverId ?? this.driverId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbTransaction copyWithCompanion(TransactionsCompanion data) {
    return DbTransaction(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      parcelType: data.parcelType.present
          ? data.parcelType.value
          : this.parcelType,
      number: data.number.present ? data.number.value : this.number,
      charges: data.charges.present ? data.charges.value : this.charges,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      cashAdvance: data.cashAdvance.present
          ? data.cashAdvance.value
          : this.cashAdvance,
      pickedUp: data.pickedUp.present ? data.pickedUp.value : this.pickedUp,
      comment: data.comment.present ? data.comment.value : this.comment,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTransaction(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('parcelType: $parcelType, ')
          ..write('number: $number, ')
          ..write('charges: $charges, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('cashAdvance: $cashAdvance, ')
          ..write('pickedUp: $pickedUp, ')
          ..write('comment: $comment, ')
          ..write('driverId: $driverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerName,
    phone,
    parcelType,
    number,
    charges,
    paymentStatus,
    cashAdvance,
    pickedUp,
    comment,
    driverId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTransaction &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.phone == this.phone &&
          other.parcelType == this.parcelType &&
          other.number == this.number &&
          other.charges == this.charges &&
          other.paymentStatus == this.paymentStatus &&
          other.cashAdvance == this.cashAdvance &&
          other.pickedUp == this.pickedUp &&
          other.comment == this.comment &&
          other.driverId == this.driverId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<DbTransaction> {
  final Value<int> id;
  final Value<String?> customerName;
  final Value<String> phone;
  final Value<String> parcelType;
  final Value<String> number;
  final Value<double> charges;
  final Value<String> paymentStatus;
  final Value<double> cashAdvance;
  final Value<bool> pickedUp;
  final Value<String?> comment;
  final Value<int> driverId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.parcelType = const Value.absent(),
    this.number = const Value.absent(),
    this.charges = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.cashAdvance = const Value.absent(),
    this.pickedUp = const Value.absent(),
    this.comment = const Value.absent(),
    this.driverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    required String phone,
    required String parcelType,
    required String number,
    this.charges = const Value.absent(),
    required String paymentStatus,
    this.cashAdvance = const Value.absent(),
    this.pickedUp = const Value.absent(),
    this.comment = const Value.absent(),
    required int driverId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : phone = Value(phone),
       parcelType = Value(parcelType),
       number = Value(number),
       paymentStatus = Value(paymentStatus),
       driverId = Value(driverId);
  static Insertable<DbTransaction> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? phone,
    Expression<String>? parcelType,
    Expression<String>? number,
    Expression<double>? charges,
    Expression<String>? paymentStatus,
    Expression<double>? cashAdvance,
    Expression<bool>? pickedUp,
    Expression<String>? comment,
    Expression<int>? driverId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (phone != null) 'phone': phone,
      if (parcelType != null) 'parcel_type': parcelType,
      if (number != null) 'number': number,
      if (charges != null) 'charges': charges,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (cashAdvance != null) 'cash_advance': cashAdvance,
      if (pickedUp != null) 'picked_up': pickedUp,
      if (comment != null) 'comment': comment,
      if (driverId != null) 'driver_id': driverId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String?>? customerName,
    Value<String>? phone,
    Value<String>? parcelType,
    Value<String>? number,
    Value<double>? charges,
    Value<String>? paymentStatus,
    Value<double>? cashAdvance,
    Value<bool>? pickedUp,
    Value<String?>? comment,
    Value<int>? driverId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      parcelType: parcelType ?? this.parcelType,
      number: number ?? this.number,
      charges: charges ?? this.charges,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cashAdvance: cashAdvance ?? this.cashAdvance,
      pickedUp: pickedUp ?? this.pickedUp,
      comment: comment ?? this.comment,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (parcelType.present) {
      map['parcel_type'] = Variable<String>(parcelType.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (charges.present) {
      map['charges'] = Variable<double>(charges.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (cashAdvance.present) {
      map['cash_advance'] = Variable<double>(cashAdvance.value);
    }
    if (pickedUp.present) {
      map['picked_up'] = Variable<bool>(pickedUp.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<int>(driverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('parcelType: $parcelType, ')
          ..write('number: $number, ')
          ..write('charges: $charges, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('cashAdvance: $cashAdvance, ')
          ..write('pickedUp: $pickedUp, ')
          ..write('comment: $comment, ')
          ..write('driverId: $driverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionEditHistoryTable extends TransactionEditHistory
    with TableInfo<$TransactionEditHistoryTable, TransactionEditHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionEditHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _editIdMeta = const VerificationMeta('editId');
  @override
  late final GeneratedColumn<int> editId = GeneratedColumn<int>(
    'edit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBeforeMeta = const VerificationMeta(
    'isBefore',
  );
  @override
  late final GeneratedColumn<bool> isBefore = GeneratedColumn<bool>(
    'is_before',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_before" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _editTimeMeta = const VerificationMeta(
    'editTime',
  );
  @override
  late final GeneratedColumn<DateTime> editTime = GeneratedColumn<DateTime>(
    'edit_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletionMeta = const VerificationMeta(
    'isDeletion',
  );
  @override
  late final GeneratedColumn<bool> isDeletion = GeneratedColumn<bool>(
    'is_deletion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deletion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelTypeMeta = const VerificationMeta(
    'parcelType',
  );
  @override
  late final GeneratedColumn<String> parcelType = GeneratedColumn<String>(
    'parcel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargesMeta = const VerificationMeta(
    'charges',
  );
  @override
  late final GeneratedColumn<double> charges = GeneratedColumn<double>(
    'charges',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashAdvanceMeta = const VerificationMeta(
    'cashAdvance',
  );
  @override
  late final GeneratedColumn<double> cashAdvance = GeneratedColumn<double>(
    'cash_advance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _pickedUpMeta = const VerificationMeta(
    'pickedUp',
  );
  @override
  late final GeneratedColumn<bool> pickedUp = GeneratedColumn<bool>(
    'picked_up',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("picked_up" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    editId,
    isBefore,
    editTime,
    isDeletion,
    transactionId,
    customerName,
    phone,
    parcelType,
    number,
    charges,
    paymentStatus,
    cashAdvance,
    pickedUp,
    comment,
    driverId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_edit_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEditHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('edit_id')) {
      context.handle(
        _editIdMeta,
        editId.isAcceptableOrUnknown(data['edit_id']!, _editIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editIdMeta);
    }
    if (data.containsKey('is_before')) {
      context.handle(
        _isBeforeMeta,
        isBefore.isAcceptableOrUnknown(data['is_before']!, _isBeforeMeta),
      );
    }
    if (data.containsKey('edit_time')) {
      context.handle(
        _editTimeMeta,
        editTime.isAcceptableOrUnknown(data['edit_time']!, _editTimeMeta),
      );
    }
    if (data.containsKey('is_deletion')) {
      context.handle(
        _isDeletionMeta,
        isDeletion.isAcceptableOrUnknown(data['is_deletion']!, _isDeletionMeta),
      );
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('parcel_type')) {
      context.handle(
        _parcelTypeMeta,
        parcelType.isAcceptableOrUnknown(data['parcel_type']!, _parcelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelTypeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('charges')) {
      context.handle(
        _chargesMeta,
        charges.isAcceptableOrUnknown(data['charges']!, _chargesMeta),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('cash_advance')) {
      context.handle(
        _cashAdvanceMeta,
        cashAdvance.isAcceptableOrUnknown(
          data['cash_advance']!,
          _cashAdvanceMeta,
        ),
      );
    }
    if (data.containsKey('picked_up')) {
      context.handle(
        _pickedUpMeta,
        pickedUp.isAcceptableOrUnknown(data['picked_up']!, _pickedUpMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionEditHistoryEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEditHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      editId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edit_id'],
      )!,
      isBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_before'],
      )!,
      editTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edit_time'],
      )!,
      isDeletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deletion'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      parcelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_type'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      charges: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charges'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      cashAdvance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cash_advance'],
      )!,
      pickedUp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}picked_up'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driver_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransactionEditHistoryTable createAlias(String alias) {
    return $TransactionEditHistoryTable(attachedDatabase, alias);
  }
}

class TransactionEditHistoryEntry extends DataClass
    implements Insertable<TransactionEditHistoryEntry> {
  final int id;
  final int editId;
  final bool isBefore;
  final DateTime editTime;
  final bool isDeletion;
  final int transactionId;
  final String? customerName;
  final String phone;
  final String parcelType;
  final String number;
  final double charges;
  final String paymentStatus;
  final double cashAdvance;
  final bool pickedUp;
  final String? comment;
  final int driverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TransactionEditHistoryEntry({
    required this.id,
    required this.editId,
    required this.isBefore,
    required this.editTime,
    required this.isDeletion,
    required this.transactionId,
    this.customerName,
    required this.phone,
    required this.parcelType,
    required this.number,
    required this.charges,
    required this.paymentStatus,
    required this.cashAdvance,
    required this.pickedUp,
    this.comment,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['edit_id'] = Variable<int>(editId);
    map['is_before'] = Variable<bool>(isBefore);
    map['edit_time'] = Variable<DateTime>(editTime);
    map['is_deletion'] = Variable<bool>(isDeletion);
    map['transaction_id'] = Variable<int>(transactionId);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['phone'] = Variable<String>(phone);
    map['parcel_type'] = Variable<String>(parcelType);
    map['number'] = Variable<String>(number);
    map['charges'] = Variable<double>(charges);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['cash_advance'] = Variable<double>(cashAdvance);
    map['picked_up'] = Variable<bool>(pickedUp);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['driver_id'] = Variable<int>(driverId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionEditHistoryCompanion toCompanion(bool nullToAbsent) {
    return TransactionEditHistoryCompanion(
      id: Value(id),
      editId: Value(editId),
      isBefore: Value(isBefore),
      editTime: Value(editTime),
      isDeletion: Value(isDeletion),
      transactionId: Value(transactionId),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      phone: Value(phone),
      parcelType: Value(parcelType),
      number: Value(number),
      charges: Value(charges),
      paymentStatus: Value(paymentStatus),
      cashAdvance: Value(cashAdvance),
      pickedUp: Value(pickedUp),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      driverId: Value(driverId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TransactionEditHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEditHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      editId: serializer.fromJson<int>(json['editId']),
      isBefore: serializer.fromJson<bool>(json['isBefore']),
      editTime: serializer.fromJson<DateTime>(json['editTime']),
      isDeletion: serializer.fromJson<bool>(json['isDeletion']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      phone: serializer.fromJson<String>(json['phone']),
      parcelType: serializer.fromJson<String>(json['parcelType']),
      number: serializer.fromJson<String>(json['number']),
      charges: serializer.fromJson<double>(json['charges']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      cashAdvance: serializer.fromJson<double>(json['cashAdvance']),
      pickedUp: serializer.fromJson<bool>(json['pickedUp']),
      comment: serializer.fromJson<String?>(json['comment']),
      driverId: serializer.fromJson<int>(json['driverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'editId': serializer.toJson<int>(editId),
      'isBefore': serializer.toJson<bool>(isBefore),
      'editTime': serializer.toJson<DateTime>(editTime),
      'isDeletion': serializer.toJson<bool>(isDeletion),
      'transactionId': serializer.toJson<int>(transactionId),
      'customerName': serializer.toJson<String?>(customerName),
      'phone': serializer.toJson<String>(phone),
      'parcelType': serializer.toJson<String>(parcelType),
      'number': serializer.toJson<String>(number),
      'charges': serializer.toJson<double>(charges),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'cashAdvance': serializer.toJson<double>(cashAdvance),
      'pickedUp': serializer.toJson<bool>(pickedUp),
      'comment': serializer.toJson<String?>(comment),
      'driverId': serializer.toJson<int>(driverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TransactionEditHistoryEntry copyWith({
    int? id,
    int? editId,
    bool? isBefore,
    DateTime? editTime,
    bool? isDeletion,
    int? transactionId,
    Value<String?> customerName = const Value.absent(),
    String? phone,
    String? parcelType,
    String? number,
    double? charges,
    String? paymentStatus,
    double? cashAdvance,
    bool? pickedUp,
    Value<String?> comment = const Value.absent(),
    int? driverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TransactionEditHistoryEntry(
    id: id ?? this.id,
    editId: editId ?? this.editId,
    isBefore: isBefore ?? this.isBefore,
    editTime: editTime ?? this.editTime,
    isDeletion: isDeletion ?? this.isDeletion,
    transactionId: transactionId ?? this.transactionId,
    customerName: customerName.present ? customerName.value : this.customerName,
    phone: phone ?? this.phone,
    parcelType: parcelType ?? this.parcelType,
    number: number ?? this.number,
    charges: charges ?? this.charges,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    cashAdvance: cashAdvance ?? this.cashAdvance,
    pickedUp: pickedUp ?? this.pickedUp,
    comment: comment.present ? comment.value : this.comment,
    driverId: driverId ?? this.driverId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TransactionEditHistoryEntry copyWithCompanion(
    TransactionEditHistoryCompanion data,
  ) {
    return TransactionEditHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      editId: data.editId.present ? data.editId.value : this.editId,
      isBefore: data.isBefore.present ? data.isBefore.value : this.isBefore,
      editTime: data.editTime.present ? data.editTime.value : this.editTime,
      isDeletion: data.isDeletion.present
          ? data.isDeletion.value
          : this.isDeletion,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      parcelType: data.parcelType.present
          ? data.parcelType.value
          : this.parcelType,
      number: data.number.present ? data.number.value : this.number,
      charges: data.charges.present ? data.charges.value : this.charges,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      cashAdvance: data.cashAdvance.present
          ? data.cashAdvance.value
          : this.cashAdvance,
      pickedUp: data.pickedUp.present ? data.pickedUp.value : this.pickedUp,
      comment: data.comment.present ? data.comment.value : this.comment,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEditHistoryEntry(')
          ..write('id: $id, ')
          ..write('editId: $editId, ')
          ..write('isBefore: $isBefore, ')
          ..write('editTime: $editTime, ')
          ..write('isDeletion: $isDeletion, ')
          ..write('transactionId: $transactionId, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('parcelType: $parcelType, ')
          ..write('number: $number, ')
          ..write('charges: $charges, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('cashAdvance: $cashAdvance, ')
          ..write('pickedUp: $pickedUp, ')
          ..write('comment: $comment, ')
          ..write('driverId: $driverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    editId,
    isBefore,
    editTime,
    isDeletion,
    transactionId,
    customerName,
    phone,
    parcelType,
    number,
    charges,
    paymentStatus,
    cashAdvance,
    pickedUp,
    comment,
    driverId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEditHistoryEntry &&
          other.id == this.id &&
          other.editId == this.editId &&
          other.isBefore == this.isBefore &&
          other.editTime == this.editTime &&
          other.isDeletion == this.isDeletion &&
          other.transactionId == this.transactionId &&
          other.customerName == this.customerName &&
          other.phone == this.phone &&
          other.parcelType == this.parcelType &&
          other.number == this.number &&
          other.charges == this.charges &&
          other.paymentStatus == this.paymentStatus &&
          other.cashAdvance == this.cashAdvance &&
          other.pickedUp == this.pickedUp &&
          other.comment == this.comment &&
          other.driverId == this.driverId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionEditHistoryCompanion
    extends UpdateCompanion<TransactionEditHistoryEntry> {
  final Value<int> id;
  final Value<int> editId;
  final Value<bool> isBefore;
  final Value<DateTime> editTime;
  final Value<bool> isDeletion;
  final Value<int> transactionId;
  final Value<String?> customerName;
  final Value<String> phone;
  final Value<String> parcelType;
  final Value<String> number;
  final Value<double> charges;
  final Value<String> paymentStatus;
  final Value<double> cashAdvance;
  final Value<bool> pickedUp;
  final Value<String?> comment;
  final Value<int> driverId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionEditHistoryCompanion({
    this.id = const Value.absent(),
    this.editId = const Value.absent(),
    this.isBefore = const Value.absent(),
    this.editTime = const Value.absent(),
    this.isDeletion = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.parcelType = const Value.absent(),
    this.number = const Value.absent(),
    this.charges = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.cashAdvance = const Value.absent(),
    this.pickedUp = const Value.absent(),
    this.comment = const Value.absent(),
    this.driverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionEditHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int editId,
    this.isBefore = const Value.absent(),
    this.editTime = const Value.absent(),
    this.isDeletion = const Value.absent(),
    required int transactionId,
    this.customerName = const Value.absent(),
    required String phone,
    required String parcelType,
    required String number,
    this.charges = const Value.absent(),
    required String paymentStatus,
    this.cashAdvance = const Value.absent(),
    this.pickedUp = const Value.absent(),
    this.comment = const Value.absent(),
    required int driverId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : editId = Value(editId),
       transactionId = Value(transactionId),
       phone = Value(phone),
       parcelType = Value(parcelType),
       number = Value(number),
       paymentStatus = Value(paymentStatus),
       driverId = Value(driverId);
  static Insertable<TransactionEditHistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? editId,
    Expression<bool>? isBefore,
    Expression<DateTime>? editTime,
    Expression<bool>? isDeletion,
    Expression<int>? transactionId,
    Expression<String>? customerName,
    Expression<String>? phone,
    Expression<String>? parcelType,
    Expression<String>? number,
    Expression<double>? charges,
    Expression<String>? paymentStatus,
    Expression<double>? cashAdvance,
    Expression<bool>? pickedUp,
    Expression<String>? comment,
    Expression<int>? driverId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (editId != null) 'edit_id': editId,
      if (isBefore != null) 'is_before': isBefore,
      if (editTime != null) 'edit_time': editTime,
      if (isDeletion != null) 'is_deletion': isDeletion,
      if (transactionId != null) 'transaction_id': transactionId,
      if (customerName != null) 'customer_name': customerName,
      if (phone != null) 'phone': phone,
      if (parcelType != null) 'parcel_type': parcelType,
      if (number != null) 'number': number,
      if (charges != null) 'charges': charges,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (cashAdvance != null) 'cash_advance': cashAdvance,
      if (pickedUp != null) 'picked_up': pickedUp,
      if (comment != null) 'comment': comment,
      if (driverId != null) 'driver_id': driverId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionEditHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? editId,
    Value<bool>? isBefore,
    Value<DateTime>? editTime,
    Value<bool>? isDeletion,
    Value<int>? transactionId,
    Value<String?>? customerName,
    Value<String>? phone,
    Value<String>? parcelType,
    Value<String>? number,
    Value<double>? charges,
    Value<String>? paymentStatus,
    Value<double>? cashAdvance,
    Value<bool>? pickedUp,
    Value<String?>? comment,
    Value<int>? driverId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionEditHistoryCompanion(
      id: id ?? this.id,
      editId: editId ?? this.editId,
      isBefore: isBefore ?? this.isBefore,
      editTime: editTime ?? this.editTime,
      isDeletion: isDeletion ?? this.isDeletion,
      transactionId: transactionId ?? this.transactionId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      parcelType: parcelType ?? this.parcelType,
      number: number ?? this.number,
      charges: charges ?? this.charges,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cashAdvance: cashAdvance ?? this.cashAdvance,
      pickedUp: pickedUp ?? this.pickedUp,
      comment: comment ?? this.comment,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (editId.present) {
      map['edit_id'] = Variable<int>(editId.value);
    }
    if (isBefore.present) {
      map['is_before'] = Variable<bool>(isBefore.value);
    }
    if (editTime.present) {
      map['edit_time'] = Variable<DateTime>(editTime.value);
    }
    if (isDeletion.present) {
      map['is_deletion'] = Variable<bool>(isDeletion.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (parcelType.present) {
      map['parcel_type'] = Variable<String>(parcelType.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (charges.present) {
      map['charges'] = Variable<double>(charges.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (cashAdvance.present) {
      map['cash_advance'] = Variable<double>(cashAdvance.value);
    }
    if (pickedUp.present) {
      map['picked_up'] = Variable<bool>(pickedUp.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<int>(driverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEditHistoryCompanion(')
          ..write('id: $id, ')
          ..write('editId: $editId, ')
          ..write('isBefore: $isBefore, ')
          ..write('editTime: $editTime, ')
          ..write('isDeletion: $isDeletion, ')
          ..write('transactionId: $transactionId, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('parcelType: $parcelType, ')
          ..write('number: $number, ')
          ..write('charges: $charges, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('cashAdvance: $cashAdvance, ')
          ..write('pickedUp: $pickedUp, ')
          ..write('comment: $comment, ')
          ..write('driverId: $driverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReportTransactionsTable extends ReportTransactions
    with TableInfo<$ReportTransactionsTable, ReportTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    driverId,
    transactionId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driver_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReportTransactionsTable createAlias(String alias) {
    return $ReportTransactionsTable(attachedDatabase, alias);
  }
}

class ReportTransaction extends DataClass
    implements Insertable<ReportTransaction> {
  final int id;
  final int driverId;
  final int transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReportTransaction({
    required this.id,
    required this.driverId,
    required this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['driver_id'] = Variable<int>(driverId);
    map['transaction_id'] = Variable<int>(transactionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReportTransactionsCompanion toCompanion(bool nullToAbsent) {
    return ReportTransactionsCompanion(
      id: Value(id),
      driverId: Value(driverId),
      transactionId: Value(transactionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReportTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportTransaction(
      id: serializer.fromJson<int>(json['id']),
      driverId: serializer.fromJson<int>(json['driverId']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'driverId': serializer.toJson<int>(driverId),
      'transactionId': serializer.toJson<int>(transactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReportTransaction copyWith({
    int? id,
    int? driverId,
    int? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReportTransaction(
    id: id ?? this.id,
    driverId: driverId ?? this.driverId,
    transactionId: transactionId ?? this.transactionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReportTransaction copyWithCompanion(ReportTransactionsCompanion data) {
    return ReportTransaction(
      id: data.id.present ? data.id.value : this.id,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportTransaction(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, driverId, transactionId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportTransaction &&
          other.id == this.id &&
          other.driverId == this.driverId &&
          other.transactionId == this.transactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReportTransactionsCompanion extends UpdateCompanion<ReportTransaction> {
  final Value<int> id;
  final Value<int> driverId;
  final Value<int> transactionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ReportTransactionsCompanion({
    this.id = const Value.absent(),
    this.driverId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReportTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int driverId,
    required int transactionId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : driverId = Value(driverId),
       transactionId = Value(transactionId);
  static Insertable<ReportTransaction> custom({
    Expression<int>? id,
    Expression<int>? driverId,
    Expression<int>? transactionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (driverId != null) 'driver_id': driverId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReportTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? driverId,
    Value<int>? transactionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ReportTransactionsCompanion(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<int>(driverId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TripMainsTable extends TripMains
    with TableInfo<$TripMainsTable, TripMain> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripMainsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _driverNameMeta = const VerificationMeta(
    'driverName',
  );
  @override
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
    'driver_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<String> carId = GeneratedColumn<String>(
    'car_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commissionMeta = const VerificationMeta(
    'commission',
  );
  @override
  late final GeneratedColumn<double> commission = GeneratedColumn<double>(
    'commission',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _laborCostMeta = const VerificationMeta(
    'laborCost',
  );
  @override
  late final GeneratedColumn<double> laborCost = GeneratedColumn<double>(
    'labor_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportPaymentMeta = const VerificationMeta(
    'supportPayment',
  );
  @override
  late final GeneratedColumn<double> supportPayment = GeneratedColumn<double>(
    'support_payment',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomFeeMeta = const VerificationMeta(
    'roomFee',
  );
  @override
  late final GeneratedColumn<double> roomFee = GeneratedColumn<double>(
    'room_fee',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    driverName,
    carId,
    commission,
    laborCost,
    supportPayment,
    roomFee,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_mains';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripMain> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('driver_name')) {
      context.handle(
        _driverNameMeta,
        driverName.isAcceptableOrUnknown(data['driver_name']!, _driverNameMeta),
      );
    } else if (isInserting) {
      context.missing(_driverNameMeta);
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carIdMeta);
    }
    if (data.containsKey('commission')) {
      context.handle(
        _commissionMeta,
        commission.isAcceptableOrUnknown(data['commission']!, _commissionMeta),
      );
    }
    if (data.containsKey('labor_cost')) {
      context.handle(
        _laborCostMeta,
        laborCost.isAcceptableOrUnknown(data['labor_cost']!, _laborCostMeta),
      );
    }
    if (data.containsKey('support_payment')) {
      context.handle(
        _supportPaymentMeta,
        supportPayment.isAcceptableOrUnknown(
          data['support_payment']!,
          _supportPaymentMeta,
        ),
      );
    }
    if (data.containsKey('room_fee')) {
      context.handle(
        _roomFeeMeta,
        roomFee.isAcceptableOrUnknown(data['room_fee']!, _roomFeeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripMain map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripMain(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      driverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_name'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_id'],
      )!,
      commission: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}commission'],
      ),
      laborCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}labor_cost'],
      ),
      supportPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}support_payment'],
      ),
      roomFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}room_fee'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TripMainsTable createAlias(String alias) {
    return $TripMainsTable(attachedDatabase, alias);
  }
}

class TripMain extends DataClass implements Insertable<TripMain> {
  final int id;
  final int date;
  final String driverName;
  final String carId;
  final double? commission;
  final double? laborCost;
  final double? supportPayment;
  final double? roomFee;
  final String? createdAt;
  final String? updatedAt;
  const TripMain({
    required this.id,
    required this.date,
    required this.driverName,
    required this.carId,
    this.commission,
    this.laborCost,
    this.supportPayment,
    this.roomFee,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<int>(date);
    map['driver_name'] = Variable<String>(driverName);
    map['car_id'] = Variable<String>(carId);
    if (!nullToAbsent || commission != null) {
      map['commission'] = Variable<double>(commission);
    }
    if (!nullToAbsent || laborCost != null) {
      map['labor_cost'] = Variable<double>(laborCost);
    }
    if (!nullToAbsent || supportPayment != null) {
      map['support_payment'] = Variable<double>(supportPayment);
    }
    if (!nullToAbsent || roomFee != null) {
      map['room_fee'] = Variable<double>(roomFee);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TripMainsCompanion toCompanion(bool nullToAbsent) {
    return TripMainsCompanion(
      id: Value(id),
      date: Value(date),
      driverName: Value(driverName),
      carId: Value(carId),
      commission: commission == null && nullToAbsent
          ? const Value.absent()
          : Value(commission),
      laborCost: laborCost == null && nullToAbsent
          ? const Value.absent()
          : Value(laborCost),
      supportPayment: supportPayment == null && nullToAbsent
          ? const Value.absent()
          : Value(supportPayment),
      roomFee: roomFee == null && nullToAbsent
          ? const Value.absent()
          : Value(roomFee),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TripMain.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripMain(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<int>(json['date']),
      driverName: serializer.fromJson<String>(json['driverName']),
      carId: serializer.fromJson<String>(json['carId']),
      commission: serializer.fromJson<double?>(json['commission']),
      laborCost: serializer.fromJson<double?>(json['laborCost']),
      supportPayment: serializer.fromJson<double?>(json['supportPayment']),
      roomFee: serializer.fromJson<double?>(json['roomFee']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<int>(date),
      'driverName': serializer.toJson<String>(driverName),
      'carId': serializer.toJson<String>(carId),
      'commission': serializer.toJson<double?>(commission),
      'laborCost': serializer.toJson<double?>(laborCost),
      'supportPayment': serializer.toJson<double?>(supportPayment),
      'roomFee': serializer.toJson<double?>(roomFee),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  TripMain copyWith({
    int? id,
    int? date,
    String? driverName,
    String? carId,
    Value<double?> commission = const Value.absent(),
    Value<double?> laborCost = const Value.absent(),
    Value<double?> supportPayment = const Value.absent(),
    Value<double?> roomFee = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => TripMain(
    id: id ?? this.id,
    date: date ?? this.date,
    driverName: driverName ?? this.driverName,
    carId: carId ?? this.carId,
    commission: commission.present ? commission.value : this.commission,
    laborCost: laborCost.present ? laborCost.value : this.laborCost,
    supportPayment: supportPayment.present
        ? supportPayment.value
        : this.supportPayment,
    roomFee: roomFee.present ? roomFee.value : this.roomFee,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TripMain copyWithCompanion(TripMainsCompanion data) {
    return TripMain(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      driverName: data.driverName.present
          ? data.driverName.value
          : this.driverName,
      carId: data.carId.present ? data.carId.value : this.carId,
      commission: data.commission.present
          ? data.commission.value
          : this.commission,
      laborCost: data.laborCost.present ? data.laborCost.value : this.laborCost,
      supportPayment: data.supportPayment.present
          ? data.supportPayment.value
          : this.supportPayment,
      roomFee: data.roomFee.present ? data.roomFee.value : this.roomFee,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripMain(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('driverName: $driverName, ')
          ..write('carId: $carId, ')
          ..write('commission: $commission, ')
          ..write('laborCost: $laborCost, ')
          ..write('supportPayment: $supportPayment, ')
          ..write('roomFee: $roomFee, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    driverName,
    carId,
    commission,
    laborCost,
    supportPayment,
    roomFee,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripMain &&
          other.id == this.id &&
          other.date == this.date &&
          other.driverName == this.driverName &&
          other.carId == this.carId &&
          other.commission == this.commission &&
          other.laborCost == this.laborCost &&
          other.supportPayment == this.supportPayment &&
          other.roomFee == this.roomFee &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripMainsCompanion extends UpdateCompanion<TripMain> {
  final Value<int> id;
  final Value<int> date;
  final Value<String> driverName;
  final Value<String> carId;
  final Value<double?> commission;
  final Value<double?> laborCost;
  final Value<double?> supportPayment;
  final Value<double?> roomFee;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  const TripMainsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.driverName = const Value.absent(),
    this.carId = const Value.absent(),
    this.commission = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.supportPayment = const Value.absent(),
    this.roomFee = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TripMainsCompanion.insert({
    this.id = const Value.absent(),
    required int date,
    required String driverName,
    required String carId,
    this.commission = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.supportPayment = const Value.absent(),
    this.roomFee = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : date = Value(date),
       driverName = Value(driverName),
       carId = Value(carId);
  static Insertable<TripMain> custom({
    Expression<int>? id,
    Expression<int>? date,
    Expression<String>? driverName,
    Expression<String>? carId,
    Expression<double>? commission,
    Expression<double>? laborCost,
    Expression<double>? supportPayment,
    Expression<double>? roomFee,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (driverName != null) 'driver_name': driverName,
      if (carId != null) 'car_id': carId,
      if (commission != null) 'commission': commission,
      if (laborCost != null) 'labor_cost': laborCost,
      if (supportPayment != null) 'support_payment': supportPayment,
      if (roomFee != null) 'room_fee': roomFee,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TripMainsCompanion copyWith({
    Value<int>? id,
    Value<int>? date,
    Value<String>? driverName,
    Value<String>? carId,
    Value<double?>? commission,
    Value<double?>? laborCost,
    Value<double?>? supportPayment,
    Value<double?>? roomFee,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
  }) {
    return TripMainsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      driverName: driverName ?? this.driverName,
      carId: carId ?? this.carId,
      commission: commission ?? this.commission,
      laborCost: laborCost ?? this.laborCost,
      supportPayment: supportPayment ?? this.supportPayment,
      roomFee: roomFee ?? this.roomFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<String>(carId.value);
    }
    if (commission.present) {
      map['commission'] = Variable<double>(commission.value);
    }
    if (laborCost.present) {
      map['labor_cost'] = Variable<double>(laborCost.value);
    }
    if (supportPayment.present) {
      map['support_payment'] = Variable<double>(supportPayment.value);
    }
    if (roomFee.present) {
      map['room_fee'] = Variable<double>(roomFee.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripMainsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('driverName: $driverName, ')
          ..write('carId: $carId, ')
          ..write('commission: $commission, ')
          ..write('laborCost: $laborCost, ')
          ..write('supportPayment: $supportPayment, ')
          ..write('roomFee: $roomFee, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TripManifestsTable extends TripManifests
    with TableInfo<$TripManifestsTable, TripManifest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripManifestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_mains (id)',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryCityMeta = const VerificationMeta(
    'deliveryCity',
  );
  @override
  late final GeneratedColumn<String> deliveryCity = GeneratedColumn<String>(
    'delivery_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parcelTypeMeta = const VerificationMeta(
    'parcelType',
  );
  @override
  late final GeneratedColumn<String> parcelType = GeneratedColumn<String>(
    'parcel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberOfParcelMeta = const VerificationMeta(
    'numberOfParcel',
  );
  @override
  late final GeneratedColumn<int> numberOfParcel = GeneratedColumn<int>(
    'number_of_parcel',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashAdvanceMeta = const VerificationMeta(
    'cashAdvance',
  );
  @override
  late final GeneratedColumn<double> cashAdvance = GeneratedColumn<double>(
    'cash_advance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentPendingMeta = const VerificationMeta(
    'paymentPending',
  );
  @override
  late final GeneratedColumn<double> paymentPending = GeneratedColumn<double>(
    'payment_pending',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentPaidMeta = const VerificationMeta(
    'paymentPaid',
  );
  @override
  late final GeneratedColumn<double> paymentPaid = GeneratedColumn<double>(
    'payment_paid',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    driverId,
    customerName,
    deliveryCity,
    phone,
    parcelType,
    numberOfParcel,
    cashAdvance,
    paymentPending,
    paymentPaid,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_manifests';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripManifest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('delivery_city')) {
      context.handle(
        _deliveryCityMeta,
        deliveryCity.isAcceptableOrUnknown(
          data['delivery_city']!,
          _deliveryCityMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('parcel_type')) {
      context.handle(
        _parcelTypeMeta,
        parcelType.isAcceptableOrUnknown(data['parcel_type']!, _parcelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelTypeMeta);
    }
    if (data.containsKey('number_of_parcel')) {
      context.handle(
        _numberOfParcelMeta,
        numberOfParcel.isAcceptableOrUnknown(
          data['number_of_parcel']!,
          _numberOfParcelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberOfParcelMeta);
    }
    if (data.containsKey('cash_advance')) {
      context.handle(
        _cashAdvanceMeta,
        cashAdvance.isAcceptableOrUnknown(
          data['cash_advance']!,
          _cashAdvanceMeta,
        ),
      );
    }
    if (data.containsKey('payment_pending')) {
      context.handle(
        _paymentPendingMeta,
        paymentPending.isAcceptableOrUnknown(
          data['payment_pending']!,
          _paymentPendingMeta,
        ),
      );
    }
    if (data.containsKey('payment_paid')) {
      context.handle(
        _paymentPaidMeta,
        paymentPaid.isAcceptableOrUnknown(
          data['payment_paid']!,
          _paymentPaidMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripManifest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripManifest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driver_id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      deliveryCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_city'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      parcelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_type'],
      )!,
      numberOfParcel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_parcel'],
      )!,
      cashAdvance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cash_advance'],
      ),
      paymentPending: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}payment_pending'],
      ),
      paymentPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}payment_paid'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TripManifestsTable createAlias(String alias) {
    return $TripManifestsTable(attachedDatabase, alias);
  }
}

class TripManifest extends DataClass implements Insertable<TripManifest> {
  final int id;
  final int driverId;
  final String? customerName;
  final String? deliveryCity;
  final String? phone;
  final String parcelType;
  final int numberOfParcel;
  final double? cashAdvance;
  final double? paymentPending;
  final double? paymentPaid;
  final String? createdAt;
  final String? updatedAt;
  const TripManifest({
    required this.id,
    required this.driverId,
    this.customerName,
    this.deliveryCity,
    this.phone,
    required this.parcelType,
    required this.numberOfParcel,
    this.cashAdvance,
    this.paymentPending,
    this.paymentPaid,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['driver_id'] = Variable<int>(driverId);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || deliveryCity != null) {
      map['delivery_city'] = Variable<String>(deliveryCity);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['parcel_type'] = Variable<String>(parcelType);
    map['number_of_parcel'] = Variable<int>(numberOfParcel);
    if (!nullToAbsent || cashAdvance != null) {
      map['cash_advance'] = Variable<double>(cashAdvance);
    }
    if (!nullToAbsent || paymentPending != null) {
      map['payment_pending'] = Variable<double>(paymentPending);
    }
    if (!nullToAbsent || paymentPaid != null) {
      map['payment_paid'] = Variable<double>(paymentPaid);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TripManifestsCompanion toCompanion(bool nullToAbsent) {
    return TripManifestsCompanion(
      id: Value(id),
      driverId: Value(driverId),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      deliveryCity: deliveryCity == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryCity),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      parcelType: Value(parcelType),
      numberOfParcel: Value(numberOfParcel),
      cashAdvance: cashAdvance == null && nullToAbsent
          ? const Value.absent()
          : Value(cashAdvance),
      paymentPending: paymentPending == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentPending),
      paymentPaid: paymentPaid == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentPaid),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TripManifest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripManifest(
      id: serializer.fromJson<int>(json['id']),
      driverId: serializer.fromJson<int>(json['driverId']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      deliveryCity: serializer.fromJson<String?>(json['deliveryCity']),
      phone: serializer.fromJson<String?>(json['phone']),
      parcelType: serializer.fromJson<String>(json['parcelType']),
      numberOfParcel: serializer.fromJson<int>(json['numberOfParcel']),
      cashAdvance: serializer.fromJson<double?>(json['cashAdvance']),
      paymentPending: serializer.fromJson<double?>(json['paymentPending']),
      paymentPaid: serializer.fromJson<double?>(json['paymentPaid']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'driverId': serializer.toJson<int>(driverId),
      'customerName': serializer.toJson<String?>(customerName),
      'deliveryCity': serializer.toJson<String?>(deliveryCity),
      'phone': serializer.toJson<String?>(phone),
      'parcelType': serializer.toJson<String>(parcelType),
      'numberOfParcel': serializer.toJson<int>(numberOfParcel),
      'cashAdvance': serializer.toJson<double?>(cashAdvance),
      'paymentPending': serializer.toJson<double?>(paymentPending),
      'paymentPaid': serializer.toJson<double?>(paymentPaid),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  TripManifest copyWith({
    int? id,
    int? driverId,
    Value<String?> customerName = const Value.absent(),
    Value<String?> deliveryCity = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? parcelType,
    int? numberOfParcel,
    Value<double?> cashAdvance = const Value.absent(),
    Value<double?> paymentPending = const Value.absent(),
    Value<double?> paymentPaid = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => TripManifest(
    id: id ?? this.id,
    driverId: driverId ?? this.driverId,
    customerName: customerName.present ? customerName.value : this.customerName,
    deliveryCity: deliveryCity.present ? deliveryCity.value : this.deliveryCity,
    phone: phone.present ? phone.value : this.phone,
    parcelType: parcelType ?? this.parcelType,
    numberOfParcel: numberOfParcel ?? this.numberOfParcel,
    cashAdvance: cashAdvance.present ? cashAdvance.value : this.cashAdvance,
    paymentPending: paymentPending.present
        ? paymentPending.value
        : this.paymentPending,
    paymentPaid: paymentPaid.present ? paymentPaid.value : this.paymentPaid,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TripManifest copyWithCompanion(TripManifestsCompanion data) {
    return TripManifest(
      id: data.id.present ? data.id.value : this.id,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      deliveryCity: data.deliveryCity.present
          ? data.deliveryCity.value
          : this.deliveryCity,
      phone: data.phone.present ? data.phone.value : this.phone,
      parcelType: data.parcelType.present
          ? data.parcelType.value
          : this.parcelType,
      numberOfParcel: data.numberOfParcel.present
          ? data.numberOfParcel.value
          : this.numberOfParcel,
      cashAdvance: data.cashAdvance.present
          ? data.cashAdvance.value
          : this.cashAdvance,
      paymentPending: data.paymentPending.present
          ? data.paymentPending.value
          : this.paymentPending,
      paymentPaid: data.paymentPaid.present
          ? data.paymentPaid.value
          : this.paymentPaid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripManifest(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('customerName: $customerName, ')
          ..write('deliveryCity: $deliveryCity, ')
          ..write('phone: $phone, ')
          ..write('parcelType: $parcelType, ')
          ..write('numberOfParcel: $numberOfParcel, ')
          ..write('cashAdvance: $cashAdvance, ')
          ..write('paymentPending: $paymentPending, ')
          ..write('paymentPaid: $paymentPaid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    driverId,
    customerName,
    deliveryCity,
    phone,
    parcelType,
    numberOfParcel,
    cashAdvance,
    paymentPending,
    paymentPaid,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripManifest &&
          other.id == this.id &&
          other.driverId == this.driverId &&
          other.customerName == this.customerName &&
          other.deliveryCity == this.deliveryCity &&
          other.phone == this.phone &&
          other.parcelType == this.parcelType &&
          other.numberOfParcel == this.numberOfParcel &&
          other.cashAdvance == this.cashAdvance &&
          other.paymentPending == this.paymentPending &&
          other.paymentPaid == this.paymentPaid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripManifestsCompanion extends UpdateCompanion<TripManifest> {
  final Value<int> id;
  final Value<int> driverId;
  final Value<String?> customerName;
  final Value<String?> deliveryCity;
  final Value<String?> phone;
  final Value<String> parcelType;
  final Value<int> numberOfParcel;
  final Value<double?> cashAdvance;
  final Value<double?> paymentPending;
  final Value<double?> paymentPaid;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  const TripManifestsCompanion({
    this.id = const Value.absent(),
    this.driverId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.deliveryCity = const Value.absent(),
    this.phone = const Value.absent(),
    this.parcelType = const Value.absent(),
    this.numberOfParcel = const Value.absent(),
    this.cashAdvance = const Value.absent(),
    this.paymentPending = const Value.absent(),
    this.paymentPaid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TripManifestsCompanion.insert({
    this.id = const Value.absent(),
    required int driverId,
    this.customerName = const Value.absent(),
    this.deliveryCity = const Value.absent(),
    this.phone = const Value.absent(),
    required String parcelType,
    required int numberOfParcel,
    this.cashAdvance = const Value.absent(),
    this.paymentPending = const Value.absent(),
    this.paymentPaid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : driverId = Value(driverId),
       parcelType = Value(parcelType),
       numberOfParcel = Value(numberOfParcel);
  static Insertable<TripManifest> custom({
    Expression<int>? id,
    Expression<int>? driverId,
    Expression<String>? customerName,
    Expression<String>? deliveryCity,
    Expression<String>? phone,
    Expression<String>? parcelType,
    Expression<int>? numberOfParcel,
    Expression<double>? cashAdvance,
    Expression<double>? paymentPending,
    Expression<double>? paymentPaid,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (driverId != null) 'driver_id': driverId,
      if (customerName != null) 'customer_name': customerName,
      if (deliveryCity != null) 'delivery_city': deliveryCity,
      if (phone != null) 'phone': phone,
      if (parcelType != null) 'parcel_type': parcelType,
      if (numberOfParcel != null) 'number_of_parcel': numberOfParcel,
      if (cashAdvance != null) 'cash_advance': cashAdvance,
      if (paymentPending != null) 'payment_pending': paymentPending,
      if (paymentPaid != null) 'payment_paid': paymentPaid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TripManifestsCompanion copyWith({
    Value<int>? id,
    Value<int>? driverId,
    Value<String?>? customerName,
    Value<String?>? deliveryCity,
    Value<String?>? phone,
    Value<String>? parcelType,
    Value<int>? numberOfParcel,
    Value<double?>? cashAdvance,
    Value<double?>? paymentPending,
    Value<double?>? paymentPaid,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
  }) {
    return TripManifestsCompanion(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      customerName: customerName ?? this.customerName,
      deliveryCity: deliveryCity ?? this.deliveryCity,
      phone: phone ?? this.phone,
      parcelType: parcelType ?? this.parcelType,
      numberOfParcel: numberOfParcel ?? this.numberOfParcel,
      cashAdvance: cashAdvance ?? this.cashAdvance,
      paymentPending: paymentPending ?? this.paymentPending,
      paymentPaid: paymentPaid ?? this.paymentPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<int>(driverId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (deliveryCity.present) {
      map['delivery_city'] = Variable<String>(deliveryCity.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (parcelType.present) {
      map['parcel_type'] = Variable<String>(parcelType.value);
    }
    if (numberOfParcel.present) {
      map['number_of_parcel'] = Variable<int>(numberOfParcel.value);
    }
    if (cashAdvance.present) {
      map['cash_advance'] = Variable<double>(cashAdvance.value);
    }
    if (paymentPending.present) {
      map['payment_pending'] = Variable<double>(paymentPending.value);
    }
    if (paymentPaid.present) {
      map['payment_paid'] = Variable<double>(paymentPaid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripManifestsCompanion(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('customerName: $customerName, ')
          ..write('deliveryCity: $deliveryCity, ')
          ..write('phone: $phone, ')
          ..write('parcelType: $parcelType, ')
          ..write('numberOfParcel: $numberOfParcel, ')
          ..write('cashAdvance: $cashAdvance, ')
          ..write('paymentPending: $paymentPending, ')
          ..write('paymentPaid: $paymentPaid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DriversTable drivers = $DriversTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionEditHistoryTable transactionEditHistory =
      $TransactionEditHistoryTable(this);
  late final $ReportTransactionsTable reportTransactions =
      $ReportTransactionsTable(this);
  late final $TripMainsTable tripMains = $TripMainsTable(this);
  late final $TripManifestsTable tripManifests = $TripManifestsTable(this);
  late final TripDao tripDao = TripDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    drivers,
    transactions,
    transactionEditHistory,
    reportTransactions,
    tripMains,
    tripManifests,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$DriversTableCreateCompanionBuilder =
    DriversCompanion Function({
      Value<int> id,
      required DateTime date,
      required String name,
      Value<double?> roomFee,
      Value<double?> laborFee,
      Value<double?> deliveryFee,
      Value<bool> paidOut,
    });
typedef $$DriversTableUpdateCompanionBuilder =
    DriversCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> name,
      Value<double?> roomFee,
      Value<double?> laborFee,
      Value<double?> deliveryFee,
      Value<bool> paidOut,
    });

final class $$DriversTableReferences
    extends BaseReferences<_$AppDatabase, $DriversTable, Driver> {
  $$DriversTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<DbTransaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(db.drivers.id, db.transactions.driverId),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TransactionEditHistoryTable,
    List<TransactionEditHistoryEntry>
  >
  _transactionEditHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionEditHistory,
        aliasName: $_aliasNameGenerator(
          db.drivers.id,
          db.transactionEditHistory.driverId,
        ),
      );

  $$TransactionEditHistoryTableProcessedTableManager
  get transactionEditHistoryRefs {
    final manager = $$TransactionEditHistoryTableTableManager(
      $_db,
      $_db.transactionEditHistory,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionEditHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReportTransactionsTable, List<ReportTransaction>>
  _reportTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reportTransactions,
        aliasName: $_aliasNameGenerator(
          db.drivers.id,
          db.reportTransactions.driverId,
        ),
      );

  $$ReportTransactionsTableProcessedTableManager get reportTransactionsRefs {
    final manager = $$ReportTransactionsTableTableManager(
      $_db,
      $_db.reportTransactions,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reportTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DriversTableFilterComposer
    extends Composer<_$AppDatabase, $DriversTable> {
  $$DriversTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roomFee => $composableBuilder(
    column: $table.roomFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get laborFee => $composableBuilder(
    column: $table.laborFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paidOut => $composableBuilder(
    column: $table.paidOut,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionEditHistoryRefs(
    Expression<bool> Function($$TransactionEditHistoryTableFilterComposer f) f,
  ) {
    final $$TransactionEditHistoryTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionEditHistory,
          getReferencedColumn: (t) => t.driverId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionEditHistoryTableFilterComposer(
                $db: $db,
                $table: $db.transactionEditHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> reportTransactionsRefs(
    Expression<bool> Function($$ReportTransactionsTableFilterComposer f) f,
  ) {
    final $$ReportTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportTransactions,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.reportTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DriversTableOrderingComposer
    extends Composer<_$AppDatabase, $DriversTable> {
  $$DriversTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roomFee => $composableBuilder(
    column: $table.roomFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get laborFee => $composableBuilder(
    column: $table.laborFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paidOut => $composableBuilder(
    column: $table.paidOut,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DriversTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriversTable> {
  $$DriversTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get roomFee =>
      $composableBuilder(column: $table.roomFee, builder: (column) => column);

  GeneratedColumn<double> get laborFee =>
      $composableBuilder(column: $table.laborFee, builder: (column) => column);

  GeneratedColumn<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paidOut =>
      $composableBuilder(column: $table.paidOut, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionEditHistoryRefs<T extends Object>(
    Expression<T> Function($$TransactionEditHistoryTableAnnotationComposer a) f,
  ) {
    final $$TransactionEditHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionEditHistory,
          getReferencedColumn: (t) => t.driverId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionEditHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionEditHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> reportTransactionsRefs<T extends Object>(
    Expression<T> Function($$ReportTransactionsTableAnnotationComposer a) f,
  ) {
    final $$ReportTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reportTransactions,
          getReferencedColumn: (t) => t.driverId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReportTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.reportTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DriversTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DriversTable,
          Driver,
          $$DriversTableFilterComposer,
          $$DriversTableOrderingComposer,
          $$DriversTableAnnotationComposer,
          $$DriversTableCreateCompanionBuilder,
          $$DriversTableUpdateCompanionBuilder,
          (Driver, $$DriversTableReferences),
          Driver,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool transactionEditHistoryRefs,
            bool reportTransactionsRefs,
          })
        > {
  $$DriversTableTableManager(_$AppDatabase db, $DriversTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriversTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriversTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriversTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> roomFee = const Value.absent(),
                Value<double?> laborFee = const Value.absent(),
                Value<double?> deliveryFee = const Value.absent(),
                Value<bool> paidOut = const Value.absent(),
              }) => DriversCompanion(
                id: id,
                date: date,
                name: name,
                roomFee: roomFee,
                laborFee: laborFee,
                deliveryFee: deliveryFee,
                paidOut: paidOut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String name,
                Value<double?> roomFee = const Value.absent(),
                Value<double?> laborFee = const Value.absent(),
                Value<double?> deliveryFee = const Value.absent(),
                Value<bool> paidOut = const Value.absent(),
              }) => DriversCompanion.insert(
                id: id,
                date: date,
                name: name,
                roomFee: roomFee,
                laborFee: laborFee,
                deliveryFee: deliveryFee,
                paidOut: paidOut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DriversTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsRefs = false,
                transactionEditHistoryRefs = false,
                reportTransactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (transactionEditHistoryRefs) db.transactionEditHistory,
                    if (reportTransactionsRefs) db.reportTransactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Driver,
                          $DriversTable,
                          DbTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionEditHistoryRefs)
                        await $_getPrefetchedData<
                          Driver,
                          $DriversTable,
                          TransactionEditHistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._transactionEditHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionEditHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportTransactionsRefs)
                        await $_getPrefetchedData<
                          Driver,
                          $DriversTable,
                          ReportTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._reportTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).reportTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DriversTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DriversTable,
      Driver,
      $$DriversTableFilterComposer,
      $$DriversTableOrderingComposer,
      $$DriversTableAnnotationComposer,
      $$DriversTableCreateCompanionBuilder,
      $$DriversTableUpdateCompanionBuilder,
      (Driver, $$DriversTableReferences),
      Driver,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool transactionEditHistoryRefs,
        bool reportTransactionsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String?> customerName,
      required String phone,
      required String parcelType,
      required String number,
      Value<double> charges,
      required String paymentStatus,
      Value<double> cashAdvance,
      Value<bool> pickedUp,
      Value<String?> comment,
      required int driverId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String?> customerName,
      Value<String> phone,
      Value<String> parcelType,
      Value<String> number,
      Value<double> charges,
      Value<String> paymentStatus,
      Value<double> cashAdvance,
      Value<bool> pickedUp,
      Value<String?> comment,
      Value<int> driverId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, DbTransaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias(
        $_aliasNameGenerator(db.transactions.driverId, db.drivers.id),
      );

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<int>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TransactionEditHistoryTable,
    List<TransactionEditHistoryEntry>
  >
  _transactionEditHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionEditHistory,
        aliasName: $_aliasNameGenerator(
          db.transactions.id,
          db.transactionEditHistory.transactionId,
        ),
      );

  $$TransactionEditHistoryTableProcessedTableManager
  get transactionEditHistoryRefs {
    final manager = $$TransactionEditHistoryTableTableManager(
      $_db,
      $_db.transactionEditHistory,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionEditHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReportTransactionsTable, List<ReportTransaction>>
  _reportTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reportTransactions,
        aliasName: $_aliasNameGenerator(
          db.transactions.id,
          db.reportTransactions.transactionId,
        ),
      );

  $$ReportTransactionsTableProcessedTableManager get reportTransactionsRefs {
    final manager = $$ReportTransactionsTableTableManager(
      $_db,
      $_db.reportTransactions,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reportTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pickedUp => $composableBuilder(
    column: $table.pickedUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionEditHistoryRefs(
    Expression<bool> Function($$TransactionEditHistoryTableFilterComposer f) f,
  ) {
    final $$TransactionEditHistoryTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionEditHistory,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionEditHistoryTableFilterComposer(
                $db: $db,
                $table: $db.transactionEditHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> reportTransactionsRefs(
    Expression<bool> Function($$ReportTransactionsTableFilterComposer f) f,
  ) {
    final $$ReportTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportTransactions,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.reportTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pickedUp => $composableBuilder(
    column: $table.pickedUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<double> get charges =>
      $composableBuilder(column: $table.charges, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pickedUp =>
      $composableBuilder(column: $table.pickedUp, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionEditHistoryRefs<T extends Object>(
    Expression<T> Function($$TransactionEditHistoryTableAnnotationComposer a) f,
  ) {
    final $$TransactionEditHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionEditHistory,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionEditHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionEditHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> reportTransactionsRefs<T extends Object>(
    Expression<T> Function($$ReportTransactionsTableAnnotationComposer a) f,
  ) {
    final $$ReportTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reportTransactions,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReportTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.reportTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          DbTransaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (DbTransaction, $$TransactionsTableReferences),
          DbTransaction,
          PrefetchHooks Function({
            bool driverId,
            bool transactionEditHistoryRefs,
            bool reportTransactionsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> parcelType = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<double> charges = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<double> cashAdvance = const Value.absent(),
                Value<bool> pickedUp = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> driverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                customerName: customerName,
                phone: phone,
                parcelType: parcelType,
                number: number,
                charges: charges,
                paymentStatus: paymentStatus,
                cashAdvance: cashAdvance,
                pickedUp: pickedUp,
                comment: comment,
                driverId: driverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                required String phone,
                required String parcelType,
                required String number,
                Value<double> charges = const Value.absent(),
                required String paymentStatus,
                Value<double> cashAdvance = const Value.absent(),
                Value<bool> pickedUp = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                required int driverId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                customerName: customerName,
                phone: phone,
                parcelType: parcelType,
                number: number,
                charges: charges,
                paymentStatus: paymentStatus,
                cashAdvance: cashAdvance,
                pickedUp: pickedUp,
                comment: comment,
                driverId: driverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                driverId = false,
                transactionEditHistoryRefs = false,
                reportTransactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionEditHistoryRefs) db.transactionEditHistory,
                    if (reportTransactionsRefs) db.reportTransactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (driverId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.driverId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._driverIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._driverIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionEditHistoryRefs)
                        await $_getPrefetchedData<
                          DbTransaction,
                          $TransactionsTable,
                          TransactionEditHistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionEditHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionEditHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportTransactionsRefs)
                        await $_getPrefetchedData<
                          DbTransaction,
                          $TransactionsTable,
                          ReportTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._reportTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).reportTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      DbTransaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (DbTransaction, $$TransactionsTableReferences),
      DbTransaction,
      PrefetchHooks Function({
        bool driverId,
        bool transactionEditHistoryRefs,
        bool reportTransactionsRefs,
      })
    >;
typedef $$TransactionEditHistoryTableCreateCompanionBuilder =
    TransactionEditHistoryCompanion Function({
      Value<int> id,
      required int editId,
      Value<bool> isBefore,
      Value<DateTime> editTime,
      Value<bool> isDeletion,
      required int transactionId,
      Value<String?> customerName,
      required String phone,
      required String parcelType,
      required String number,
      Value<double> charges,
      required String paymentStatus,
      Value<double> cashAdvance,
      Value<bool> pickedUp,
      Value<String?> comment,
      required int driverId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionEditHistoryTableUpdateCompanionBuilder =
    TransactionEditHistoryCompanion Function({
      Value<int> id,
      Value<int> editId,
      Value<bool> isBefore,
      Value<DateTime> editTime,
      Value<bool> isDeletion,
      Value<int> transactionId,
      Value<String?> customerName,
      Value<String> phone,
      Value<String> parcelType,
      Value<String> number,
      Value<double> charges,
      Value<String> paymentStatus,
      Value<double> cashAdvance,
      Value<bool> pickedUp,
      Value<String?> comment,
      Value<int> driverId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionEditHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionEditHistoryTable,
          TransactionEditHistoryEntry
        > {
  $$TransactionEditHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.transactionEditHistory.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias(
        $_aliasNameGenerator(db.transactionEditHistory.driverId, db.drivers.id),
      );

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<int>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionEditHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionEditHistoryTable> {
  $$TransactionEditHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editId => $composableBuilder(
    column: $table.editId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBefore => $composableBuilder(
    column: $table.isBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editTime => $composableBuilder(
    column: $table.editTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeletion => $composableBuilder(
    column: $table.isDeletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pickedUp => $composableBuilder(
    column: $table.pickedUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionEditHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionEditHistoryTable> {
  $$TransactionEditHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editId => $composableBuilder(
    column: $table.editId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBefore => $composableBuilder(
    column: $table.isBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editTime => $composableBuilder(
    column: $table.editTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeletion => $composableBuilder(
    column: $table.isDeletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pickedUp => $composableBuilder(
    column: $table.pickedUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionEditHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionEditHistoryTable> {
  $$TransactionEditHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get editId =>
      $composableBuilder(column: $table.editId, builder: (column) => column);

  GeneratedColumn<bool> get isBefore =>
      $composableBuilder(column: $table.isBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get editTime =>
      $composableBuilder(column: $table.editTime, builder: (column) => column);

  GeneratedColumn<bool> get isDeletion => $composableBuilder(
    column: $table.isDeletion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<double> get charges =>
      $composableBuilder(column: $table.charges, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pickedUp =>
      $composableBuilder(column: $table.pickedUp, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionEditHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionEditHistoryTable,
          TransactionEditHistoryEntry,
          $$TransactionEditHistoryTableFilterComposer,
          $$TransactionEditHistoryTableOrderingComposer,
          $$TransactionEditHistoryTableAnnotationComposer,
          $$TransactionEditHistoryTableCreateCompanionBuilder,
          $$TransactionEditHistoryTableUpdateCompanionBuilder,
          (
            TransactionEditHistoryEntry,
            $$TransactionEditHistoryTableReferences,
          ),
          TransactionEditHistoryEntry,
          PrefetchHooks Function({bool transactionId, bool driverId})
        > {
  $$TransactionEditHistoryTableTableManager(
    _$AppDatabase db,
    $TransactionEditHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionEditHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TransactionEditHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionEditHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> editId = const Value.absent(),
                Value<bool> isBefore = const Value.absent(),
                Value<DateTime> editTime = const Value.absent(),
                Value<bool> isDeletion = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> parcelType = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<double> charges = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<double> cashAdvance = const Value.absent(),
                Value<bool> pickedUp = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> driverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionEditHistoryCompanion(
                id: id,
                editId: editId,
                isBefore: isBefore,
                editTime: editTime,
                isDeletion: isDeletion,
                transactionId: transactionId,
                customerName: customerName,
                phone: phone,
                parcelType: parcelType,
                number: number,
                charges: charges,
                paymentStatus: paymentStatus,
                cashAdvance: cashAdvance,
                pickedUp: pickedUp,
                comment: comment,
                driverId: driverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int editId,
                Value<bool> isBefore = const Value.absent(),
                Value<DateTime> editTime = const Value.absent(),
                Value<bool> isDeletion = const Value.absent(),
                required int transactionId,
                Value<String?> customerName = const Value.absent(),
                required String phone,
                required String parcelType,
                required String number,
                Value<double> charges = const Value.absent(),
                required String paymentStatus,
                Value<double> cashAdvance = const Value.absent(),
                Value<bool> pickedUp = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                required int driverId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionEditHistoryCompanion.insert(
                id: id,
                editId: editId,
                isBefore: isBefore,
                editTime: editTime,
                isDeletion: isDeletion,
                transactionId: transactionId,
                customerName: customerName,
                phone: phone,
                parcelType: parcelType,
                number: number,
                charges: charges,
                paymentStatus: paymentStatus,
                cashAdvance: cashAdvance,
                pickedUp: pickedUp,
                comment: comment,
                driverId: driverId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionEditHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false, driverId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionEditHistoryTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionEditHistoryTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (driverId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.driverId,
                                referencedTable:
                                    $$TransactionEditHistoryTableReferences
                                        ._driverIdTable(db),
                                referencedColumn:
                                    $$TransactionEditHistoryTableReferences
                                        ._driverIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionEditHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionEditHistoryTable,
      TransactionEditHistoryEntry,
      $$TransactionEditHistoryTableFilterComposer,
      $$TransactionEditHistoryTableOrderingComposer,
      $$TransactionEditHistoryTableAnnotationComposer,
      $$TransactionEditHistoryTableCreateCompanionBuilder,
      $$TransactionEditHistoryTableUpdateCompanionBuilder,
      (TransactionEditHistoryEntry, $$TransactionEditHistoryTableReferences),
      TransactionEditHistoryEntry,
      PrefetchHooks Function({bool transactionId, bool driverId})
    >;
typedef $$ReportTransactionsTableCreateCompanionBuilder =
    ReportTransactionsCompanion Function({
      Value<int> id,
      required int driverId,
      required int transactionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ReportTransactionsTableUpdateCompanionBuilder =
    ReportTransactionsCompanion Function({
      Value<int> id,
      Value<int> driverId,
      Value<int> transactionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ReportTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReportTransactionsTable,
          ReportTransaction
        > {
  $$ReportTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias(
        $_aliasNameGenerator(db.reportTransactions.driverId, db.drivers.id),
      );

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<int>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.reportTransactions.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReportTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportTransactionsTable> {
  $$ReportTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportTransactionsTable> {
  $$ReportTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportTransactionsTable> {
  $$ReportTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportTransactionsTable,
          ReportTransaction,
          $$ReportTransactionsTableFilterComposer,
          $$ReportTransactionsTableOrderingComposer,
          $$ReportTransactionsTableAnnotationComposer,
          $$ReportTransactionsTableCreateCompanionBuilder,
          $$ReportTransactionsTableUpdateCompanionBuilder,
          (ReportTransaction, $$ReportTransactionsTableReferences),
          ReportTransaction,
          PrefetchHooks Function({bool driverId, bool transactionId})
        > {
  $$ReportTransactionsTableTableManager(
    _$AppDatabase db,
    $ReportTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> driverId = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReportTransactionsCompanion(
                id: id,
                driverId: driverId,
                transactionId: transactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int driverId,
                required int transactionId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReportTransactionsCompanion.insert(
                id: id,
                driverId: driverId,
                transactionId: transactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReportTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({driverId = false, transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (driverId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.driverId,
                                referencedTable:
                                    $$ReportTransactionsTableReferences
                                        ._driverIdTable(db),
                                referencedColumn:
                                    $$ReportTransactionsTableReferences
                                        ._driverIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$ReportTransactionsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$ReportTransactionsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReportTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportTransactionsTable,
      ReportTransaction,
      $$ReportTransactionsTableFilterComposer,
      $$ReportTransactionsTableOrderingComposer,
      $$ReportTransactionsTableAnnotationComposer,
      $$ReportTransactionsTableCreateCompanionBuilder,
      $$ReportTransactionsTableUpdateCompanionBuilder,
      (ReportTransaction, $$ReportTransactionsTableReferences),
      ReportTransaction,
      PrefetchHooks Function({bool driverId, bool transactionId})
    >;
typedef $$TripMainsTableCreateCompanionBuilder =
    TripMainsCompanion Function({
      Value<int> id,
      required int date,
      required String driverName,
      required String carId,
      Value<double?> commission,
      Value<double?> laborCost,
      Value<double?> supportPayment,
      Value<double?> roomFee,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });
typedef $$TripMainsTableUpdateCompanionBuilder =
    TripMainsCompanion Function({
      Value<int> id,
      Value<int> date,
      Value<String> driverName,
      Value<String> carId,
      Value<double?> commission,
      Value<double?> laborCost,
      Value<double?> supportPayment,
      Value<double?> roomFee,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });

final class $$TripMainsTableReferences
    extends BaseReferences<_$AppDatabase, $TripMainsTable, TripMain> {
  $$TripMainsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripManifestsTable, List<TripManifest>>
  _tripManifestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripManifests,
    aliasName: $_aliasNameGenerator(db.tripMains.id, db.tripManifests.driverId),
  );

  $$TripManifestsTableProcessedTableManager get tripManifestsRefs {
    final manager = $$TripManifestsTableTableManager(
      $_db,
      $_db.tripManifests,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripManifestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripMainsTableFilterComposer
    extends Composer<_$AppDatabase, $TripMainsTable> {
  $$TripMainsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get supportPayment => $composableBuilder(
    column: $table.supportPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roomFee => $composableBuilder(
    column: $table.roomFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripManifestsRefs(
    Expression<bool> Function($$TripManifestsTableFilterComposer f) f,
  ) {
    final $$TripManifestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripManifests,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripManifestsTableFilterComposer(
            $db: $db,
            $table: $db.tripManifests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripMainsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripMainsTable> {
  $$TripMainsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get supportPayment => $composableBuilder(
    column: $table.supportPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roomFee => $composableBuilder(
    column: $table.roomFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripMainsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripMainsTable> {
  $$TripMainsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get carId =>
      $composableBuilder(column: $table.carId, builder: (column) => column);

  GeneratedColumn<double> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => column,
  );

  GeneratedColumn<double> get laborCost =>
      $composableBuilder(column: $table.laborCost, builder: (column) => column);

  GeneratedColumn<double> get supportPayment => $composableBuilder(
    column: $table.supportPayment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get roomFee =>
      $composableBuilder(column: $table.roomFee, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tripManifestsRefs<T extends Object>(
    Expression<T> Function($$TripManifestsTableAnnotationComposer a) f,
  ) {
    final $$TripManifestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripManifests,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripManifestsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripManifests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripMainsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripMainsTable,
          TripMain,
          $$TripMainsTableFilterComposer,
          $$TripMainsTableOrderingComposer,
          $$TripMainsTableAnnotationComposer,
          $$TripMainsTableCreateCompanionBuilder,
          $$TripMainsTableUpdateCompanionBuilder,
          (TripMain, $$TripMainsTableReferences),
          TripMain,
          PrefetchHooks Function({bool tripManifestsRefs})
        > {
  $$TripMainsTableTableManager(_$AppDatabase db, $TripMainsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripMainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripMainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripMainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<String> driverName = const Value.absent(),
                Value<String> carId = const Value.absent(),
                Value<double?> commission = const Value.absent(),
                Value<double?> laborCost = const Value.absent(),
                Value<double?> supportPayment = const Value.absent(),
                Value<double?> roomFee = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TripMainsCompanion(
                id: id,
                date: date,
                driverName: driverName,
                carId: carId,
                commission: commission,
                laborCost: laborCost,
                supportPayment: supportPayment,
                roomFee: roomFee,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int date,
                required String driverName,
                required String carId,
                Value<double?> commission = const Value.absent(),
                Value<double?> laborCost = const Value.absent(),
                Value<double?> supportPayment = const Value.absent(),
                Value<double?> roomFee = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TripMainsCompanion.insert(
                id: id,
                date: date,
                driverName: driverName,
                carId: carId,
                commission: commission,
                laborCost: laborCost,
                supportPayment: supportPayment,
                roomFee: roomFee,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripMainsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripManifestsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tripManifestsRefs) db.tripManifests,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tripManifestsRefs)
                    await $_getPrefetchedData<
                      TripMain,
                      $TripMainsTable,
                      TripManifest
                    >(
                      currentTable: table,
                      referencedTable: $$TripMainsTableReferences
                          ._tripManifestsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TripMainsTableReferences(
                            db,
                            table,
                            p0,
                          ).tripManifestsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.driverId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TripMainsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripMainsTable,
      TripMain,
      $$TripMainsTableFilterComposer,
      $$TripMainsTableOrderingComposer,
      $$TripMainsTableAnnotationComposer,
      $$TripMainsTableCreateCompanionBuilder,
      $$TripMainsTableUpdateCompanionBuilder,
      (TripMain, $$TripMainsTableReferences),
      TripMain,
      PrefetchHooks Function({bool tripManifestsRefs})
    >;
typedef $$TripManifestsTableCreateCompanionBuilder =
    TripManifestsCompanion Function({
      Value<int> id,
      required int driverId,
      Value<String?> customerName,
      Value<String?> deliveryCity,
      Value<String?> phone,
      required String parcelType,
      required int numberOfParcel,
      Value<double?> cashAdvance,
      Value<double?> paymentPending,
      Value<double?> paymentPaid,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });
typedef $$TripManifestsTableUpdateCompanionBuilder =
    TripManifestsCompanion Function({
      Value<int> id,
      Value<int> driverId,
      Value<String?> customerName,
      Value<String?> deliveryCity,
      Value<String?> phone,
      Value<String> parcelType,
      Value<int> numberOfParcel,
      Value<double?> cashAdvance,
      Value<double?> paymentPending,
      Value<double?> paymentPaid,
      Value<String?> createdAt,
      Value<String?> updatedAt,
    });

final class $$TripManifestsTableReferences
    extends BaseReferences<_$AppDatabase, $TripManifestsTable, TripManifest> {
  $$TripManifestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripMainsTable _driverIdTable(_$AppDatabase db) =>
      db.tripMains.createAlias(
        $_aliasNameGenerator(db.tripManifests.driverId, db.tripMains.id),
      );

  $$TripMainsTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<int>('driver_id')!;

    final manager = $$TripMainsTableTableManager(
      $_db,
      $_db.tripMains,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripManifestsTableFilterComposer
    extends Composer<_$AppDatabase, $TripManifestsTable> {
  $$TripManifestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryCity => $composableBuilder(
    column: $table.deliveryCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfParcel => $composableBuilder(
    column: $table.numberOfParcel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paymentPending => $composableBuilder(
    column: $table.paymentPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paymentPaid => $composableBuilder(
    column: $table.paymentPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripMainsTableFilterComposer get driverId {
    final $$TripMainsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.tripMains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMainsTableFilterComposer(
            $db: $db,
            $table: $db.tripMains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripManifestsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripManifestsTable> {
  $$TripManifestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryCity => $composableBuilder(
    column: $table.deliveryCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfParcel => $composableBuilder(
    column: $table.numberOfParcel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paymentPending => $composableBuilder(
    column: $table.paymentPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paymentPaid => $composableBuilder(
    column: $table.paymentPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripMainsTableOrderingComposer get driverId {
    final $$TripMainsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.tripMains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMainsTableOrderingComposer(
            $db: $db,
            $table: $db.tripMains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripManifestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripManifestsTable> {
  $$TripManifestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryCity => $composableBuilder(
    column: $table.deliveryCity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get parcelType => $composableBuilder(
    column: $table.parcelType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numberOfParcel => $composableBuilder(
    column: $table.numberOfParcel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cashAdvance => $composableBuilder(
    column: $table.cashAdvance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paymentPending => $composableBuilder(
    column: $table.paymentPending,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paymentPaid => $composableBuilder(
    column: $table.paymentPaid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TripMainsTableAnnotationComposer get driverId {
    final $$TripMainsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.tripMains,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripMainsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripMains,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripManifestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripManifestsTable,
          TripManifest,
          $$TripManifestsTableFilterComposer,
          $$TripManifestsTableOrderingComposer,
          $$TripManifestsTableAnnotationComposer,
          $$TripManifestsTableCreateCompanionBuilder,
          $$TripManifestsTableUpdateCompanionBuilder,
          (TripManifest, $$TripManifestsTableReferences),
          TripManifest,
          PrefetchHooks Function({bool driverId})
        > {
  $$TripManifestsTableTableManager(_$AppDatabase db, $TripManifestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripManifestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripManifestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripManifestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> driverId = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> deliveryCity = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> parcelType = const Value.absent(),
                Value<int> numberOfParcel = const Value.absent(),
                Value<double?> cashAdvance = const Value.absent(),
                Value<double?> paymentPending = const Value.absent(),
                Value<double?> paymentPaid = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TripManifestsCompanion(
                id: id,
                driverId: driverId,
                customerName: customerName,
                deliveryCity: deliveryCity,
                phone: phone,
                parcelType: parcelType,
                numberOfParcel: numberOfParcel,
                cashAdvance: cashAdvance,
                paymentPending: paymentPending,
                paymentPaid: paymentPaid,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int driverId,
                Value<String?> customerName = const Value.absent(),
                Value<String?> deliveryCity = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String parcelType,
                required int numberOfParcel,
                Value<double?> cashAdvance = const Value.absent(),
                Value<double?> paymentPending = const Value.absent(),
                Value<double?> paymentPaid = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TripManifestsCompanion.insert(
                id: id,
                driverId: driverId,
                customerName: customerName,
                deliveryCity: deliveryCity,
                phone: phone,
                parcelType: parcelType,
                numberOfParcel: numberOfParcel,
                cashAdvance: cashAdvance,
                paymentPending: paymentPending,
                paymentPaid: paymentPaid,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripManifestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({driverId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (driverId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.driverId,
                                referencedTable: $$TripManifestsTableReferences
                                    ._driverIdTable(db),
                                referencedColumn: $$TripManifestsTableReferences
                                    ._driverIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripManifestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripManifestsTable,
      TripManifest,
      $$TripManifestsTableFilterComposer,
      $$TripManifestsTableOrderingComposer,
      $$TripManifestsTableAnnotationComposer,
      $$TripManifestsTableCreateCompanionBuilder,
      $$TripManifestsTableUpdateCompanionBuilder,
      (TripManifest, $$TripManifestsTableReferences),
      TripManifest,
      PrefetchHooks Function({bool driverId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DriversTableTableManager get drivers =>
      $$DriversTableTableManager(_db, _db.drivers);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionEditHistoryTableTableManager get transactionEditHistory =>
      $$TransactionEditHistoryTableTableManager(
        _db,
        _db.transactionEditHistory,
      );
  $$ReportTransactionsTableTableManager get reportTransactions =>
      $$ReportTransactionsTableTableManager(_db, _db.reportTransactions);
  $$TripMainsTableTableManager get tripMains =>
      $$TripMainsTableTableManager(_db, _db.tripMains);
  $$TripManifestsTableTableManager get tripManifests =>
      $$TripManifestsTableTableManager(_db, _db.tripManifests);
}
