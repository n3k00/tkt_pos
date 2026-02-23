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
import 'package:myanmar_tools/myanmar_tools.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/format.dart';

class DriverPrintController extends GetxController {
  DriverPrintController(this.driverId);

  final int driverId;
  final AppDatabase _db = AppDatabase();
  final ZawGyiConverter _zgConverter = ZawGyiConverter();

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
    if (Get.isRegistered<InventoryController>()) {
      final inventoryController = Get.find<InventoryController>();
      await inventoryController.refreshDriverById(driverId);
    }
  }

  Future<Uint8List> _buildPdfBytes(Driver currentDriver) async {
    final fontData = await rootBundle.load('assets/fonts/ZAWGYI_ONE.TTF');
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

    List<List<String>> buildDataRows() {
      final rows = <List<String>>[];
      for (final entry in transactions.asMap().entries) {
        final index = entry.key + 1;
        final t = entry.value;
        rows.add([
          _zg('$index'),
          _zg(t.customerName ?? '-'),
          _zg(t.phone),
          _zg(t.parcelType),
          _zg(t.number),
          _zg(Format.money(t.charges)),
          _zg(t.paymentStatus),
          _zg(Format.money(t.cashAdvance)),
          _zg(''),
          _zg(t.comment ?? '-'),
        ]);
      }
      return rows;
    }

    List<List<String>> summaryRows() {
      final rows = <List<String>>[
        [
          _zg(''),
          _zg('Total Charges (Pending)'),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(Format.money(totalChargesPending)),
          _zg(''),
          _zg(Format.money(totalCashAdvance)),
          _zg(''),
          _zg(''),
        ],
      ];

      void addDeductionRow(String label, double amount) {
        if (amount <= 0) return;
        rows.add([
          _zg(''),
          _zg(label),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg('-${Format.money(amount)}'),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(''),
        ]);
      }

      addDeductionRow('Room Fee', roomFeeValue);
      addDeductionRow('Labor Fee', laborFeeValue);
      addDeductionRow('Delivery Fee', deliveryFeeValue);

      rows.addAll([
        [
          _zg(''),
          _zg('Paid Out Amount'),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(Format.money(netAmount)),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(''),
        ],
        [
          _zg(''),
          _zg('Paid out status'),
          _zg(paidOut.value ? 'ငွေထုတ်ပေးပြီး' : 'ငွေထုတ်ရန် ကျန်'),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(''),
          _zg(''),
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
    ].map(_zg).toList();

    final chunkSize = 13;
    final dataRows = buildDataRows();
    final dataChunks = <List<List<String>>>[];
    for (var i = 0; i < dataRows.length; i += chunkSize) {
      dataChunks.add(
        dataRows.sublist(
          i,
          i + chunkSize > dataRows.length ? dataRows.length : i + chunkSize,
        ),
      );
    }
    if (dataChunks.isEmpty) {
      dataChunks.add([]);
    }
    final summary = summaryRows();

    for (var i = 0; i < dataChunks.length; i++) {
      final chunk = dataChunks[i];
      final isLast = i == dataChunks.length - 1;
      if (isLast) {
        chunk.addAll(summary);
      }

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
                  pw.Text(_zg('Incoming Parcel Slip'), style: headerStyle),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          _zg('Driver: ${currentDriver.name}'),
                          style: subtitleStyle,
                        ),
                      ),
                      pw.Text(
                        _zg('Date: ${Format.date(currentDriver.date)}'),
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  pw.TableHelper.fromTextArray(
                    headers: headers,
                    data: chunk,
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
                  if (!isLast)
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        _zg('Continued on next page...'),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          ],
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              _zg('Page ${context.pageNumber} / ${context.pagesCount}'),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ),
      );
    }

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

  String _zg(String value) => _zgConverter.unicodeToZawGyi(value);
}
