import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/strings.dart';

class DriverPrintController extends GetxController {
  DriverPrintController(this.driverId);

  final int driverId;
  final AppDatabase _db = AppDatabase();

  final RxBool isLoading = true.obs;
  final Rxn<Driver> driver = Rxn<Driver>();
  final RxList<DbTransaction> transactions = <DbTransaction>[].obs;
  final RxBool paidOut = false.obs;

  final TextEditingController roomFeeCtrl = TextEditingController(text: '0');
  final TextEditingController laborFeeCtrl = TextEditingController(text: '0');
  final TextEditingController deliveryFeeCtrl = TextEditingController(
    text: '0',
  );

  final RxDouble roomFee = 0.0.obs;
  final RxDouble laborFee = 0.0.obs;
  final RxDouble deliveryFee = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    roomFeeCtrl.addListener(_onFeesChanged);
    laborFeeCtrl.addListener(_onFeesChanged);
    deliveryFeeCtrl.addListener(_onFeesChanged);
    _load();
  }

  @override
  void onClose() {
    roomFeeCtrl.removeListener(_onFeesChanged);
    laborFeeCtrl.removeListener(_onFeesChanged);
    deliveryFeeCtrl.removeListener(_onFeesChanged);
    roomFeeCtrl.dispose();
    laborFeeCtrl.dispose();
    deliveryFeeCtrl.dispose();
    super.onClose();
  }

  void _onFeesChanged() {
    roomFee.value = _parse(roomFeeCtrl.text);
    laborFee.value = _parse(laborFeeCtrl.text);
    deliveryFee.value = _parse(deliveryFeeCtrl.text);
  }

  double _parse(String value) {
    final parsed = double.tryParse(value.trim());
    return parsed ?? 0;
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final d = await _db.getDriverById(driverId);
      driver.value = d;
      if (d != null) {
        final txs = await _db.getTransactionsByDriver(driverId);
        transactions.assignAll(txs);
        roomFee.value = d.roomFee ?? 0;
        laborFee.value = d.laborFee ?? 0;
        deliveryFee.value = d.deliveryFee ?? 0;
        roomFeeCtrl.text = roomFee.value.toStringAsFixed(0);
        laborFeeCtrl.text = laborFee.value.toStringAsFixed(0);
        deliveryFeeCtrl.text = deliveryFee.value.toStringAsFixed(0);
        paidOut.value = d.paidOut;
      } else {
        transactions.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  double get totalChargesPending => transactions
      .where((t) => t.paymentStatus.trim() == AppString.paymentPending)
      .fold<double>(0, (sum, t) => sum + t.charges);

  double get totalCashAdvance =>
      transactions.fold<double>(0, (sum, t) => sum + t.cashAdvance);

  double get roomFeeValue => roomFee.value;
  double get laborFeeValue => laborFee.value;
  double get deliveryFeeValue => deliveryFee.value;

  double get totalDeductions => roomFeeValue + laborFeeValue + deliveryFeeValue;

  double get netAmount => totalChargesPending - totalDeductions;

  Future<void> saveAdjustments() async {
    await _db
        .update(_db.drivers)
        .replace(
          DriversCompanion(
            id: drift.Value(driverId),
            roomFee: drift.Value(roomFeeValue),
            laborFee: drift.Value(laborFeeValue),
            deliveryFee: drift.Value(deliveryFeeValue),
            paidOut: drift.Value(paidOut.value),
          ),
        );
  }

  void setPaidOut(bool value) {
    paidOut.value = value;
  }
}
