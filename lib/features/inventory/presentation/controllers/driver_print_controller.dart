import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/format.dart';

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

  void _ensureFeeDefaults() {
    void ensure(TextEditingController ctrl) {
      if (ctrl.text.trim().isEmpty) ctrl.text = '0';
    }

    ensure(roomFeeCtrl);
    ensure(laborFeeCtrl);
    ensure(deliveryFeeCtrl);
  }

  Future<void> saveAdjustments() async {
    final currentDriver = driver.value;
    if (currentDriver == null) return;

    final updatedDriver = currentDriver.copyWith(
      roomFee: drift.Value(roomFeeValue),
      laborFee: drift.Value(laborFeeValue),
      deliveryFee: drift.Value(deliveryFeeValue),
      paidOut: paidOut.value,
    );

    await _db
        .update(_db.drivers)
        .replace(
          DriversCompanion(
            id: drift.Value(driverId),
            date: drift.Value(updatedDriver.date),
            name: drift.Value(updatedDriver.name),
            roomFee: drift.Value(roomFeeValue),
            laborFee: drift.Value(laborFeeValue),
            deliveryFee: drift.Value(deliveryFeeValue),
            paidOut: drift.Value(paidOut.value),
          ),
        );
    driver.value = updatedDriver;
  }

  Future<Uint8List> _buildPdfBytes(Driver currentDriver) async {
    final fontData = await rootBundle.load(
      'assets/fonts/Pyidaungsu_Regular.ttf',
    );
    final unicodeFont = pw.Font.ttf(fontData);
    final pdfTheme = pw.ThemeData.withFont(
      base: unicodeFont,
      bold: unicodeFont,
      italic: unicodeFont,
    );

    final doc = pw.Document();
    final headerStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
    );
    final subtitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );
    final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    List<List<String>> buildTableRows() {
      final rows = <List<String>>[];
      for (final entry in transactions.asMap().entries) {
        final index = entry.key + 1;
        final t = entry.value;
        rows.add([
          '$index',
          t.customerName ?? '-',
          t.phone,
          t.parcelType,
          t.number,
          Format.money(t.charges),
          t.paymentStatus,
          Format.money(t.cashAdvance),
          '',
          t.comment ?? '-',
        ]);
      }
      rows.add([
        '',
        'Total Charges (Pending)',
        '',
        '',
        '',
        Format.money(totalChargesPending),
        '',
        Format.money(totalCashAdvance),
        '',
        '',
      ]);
      void addDeductionRow(String label, double amount) {
        if (amount <= 0) return;
        rows.add([
          '',
          label,
          '',
          '',
          '',
          '-${Format.money(amount)}',
          '',
          '',
          '',
          '',
        ]);
      }

      addDeductionRow('Room Fee', roomFeeValue);
      addDeductionRow('Labor Fee', laborFeeValue);
      addDeductionRow('Delivery Fee', deliveryFeeValue);
      rows.addAll([
        [
          '',
          'Paid Out Amount',
          '',
          '',
          '',
          Format.money(netAmount),
          '',
          '',
          '',
          '',
        ],
        [
          '',
          'Paid out status',
          paidOut.value ? 'ငွေထုတ်ပေးပြီး' : 'ငွေထုတ်ရန် ကျန်',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
        ],
      ]);

      return rows;
    }

    final headers = [
      AppString.colNo,
      AppString.colCustomerName,
      AppString.colPhone,
      AppString.colParcelType,
      AppString.colNumber,
      AppString.colCharges,
      AppString.colPaymentStatus,
      AppString.colCashAdvance,
      'Signed',
      AppString.colComment,
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        theme: pdfTheme,
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Incoming Parcel Slip', style: headerStyle),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Driver: ${currentDriver.name}',
                        style: subtitleStyle,
                      ),
                    ),
                    pw.Text(
                      'Date: ${Format.date(currentDriver.date)}',
                      style: subtitleStyle,
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.TableHelper.fromTextArray(
                  headers: headers,
                  data: buildTableRows(),
                  headerStyle: bold,
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignments: {
                    5: pw.Alignment.centerRight,
                    7: pw.Alignment.centerRight,
                  },
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30),
                    2: const pw.FixedColumnWidth(90),
                    4: const pw.FixedColumnWidth(70),
                    5: const pw.FixedColumnWidth(80),
                    7: const pw.FixedColumnWidth(90),
                    8: const pw.FixedColumnWidth(70),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> _openPdfOnWindows(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}\\driver_slip_${driverId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    await Process.run('cmd', ['/c', 'start', '', file.path], runInShell: true);
  }

  Future<void> printSlip() async {
    final currentDriver = driver.value;
    if (currentDriver == null) return;

    _ensureFeeDefaults();
    await saveAdjustments();

    final bytes = await _buildPdfBytes(currentDriver);
    if (Platform.isWindows) {
      await _openPdfOnWindows(bytes);
    } else {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
    }
  }

  void setPaidOut(bool value) {
    paidOut.value = value;
  }
}
