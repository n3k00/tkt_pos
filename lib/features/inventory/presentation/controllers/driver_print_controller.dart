import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
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
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/utils/money_input.dart';
import 'package:tkt_pos/utils/payout_calculator.dart';

Future<Uint8List> _buildDriverSlipPdf(Map<String, dynamic> snapshot) {
  final converter = ZawGyiConverter();
  String zg(String value) => converter.unicodeToZawGyi(value);
  String pdfText(String? value, {int maxChars = 36}) {
    final normalized = (value ?? '-').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '-';
    if (normalized.characters.length <= maxChars) return normalized;
    return '${normalized.characters.take(maxChars - 1).toString()}…';
  }

  final fontBytes = snapshot['fontBytes'] as Uint8List;
  final pdfTheme = pw.ThemeData.withFont(
    base: pw.Font.ttf(fontBytes.buffer.asByteData()),
    bold: pw.Font.ttf(fontBytes.buffer.asByteData()),
    italic: pw.Font.ttf(fontBytes.buffer.asByteData()),
  );

  final doc = pw.Document();
  final headerStyle = pw.TextStyle(
    fontSize: Dimens.fontSizeTitle,
    fontWeight: pw.FontWeight.bold,
  );
  final subtitleStyle = pw.TextStyle(
    fontSize: Dimens.fontSizeCaption,
    fontWeight: pw.FontWeight.bold,
  );
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);

  final driverName = snapshot['driverName'] as String;
  final driverDate = snapshot['driverDate'] as String;
  final totalCharges = snapshot['totalCharges'] as double;
  final totalChargesPaid = snapshot['totalChargesPaid'] as double;
  final totalChargesPending = snapshot['totalChargesPending'] as double;
  final totalCashAdvance = snapshot['totalCashAdvance'] as double;
  final roomFeeValue = snapshot['roomFeeValue'] as double;
  final laborFeeValue = snapshot['laborFeeValue'] as double;
  final deliveryFeeValue = snapshot['deliveryFeeValue'] as double;
  final netAmount = snapshot['netAmount'] as double;
  final paidOut = snapshot['paidOut'] as bool;

  final rawTransactions = (snapshot['transactions'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final dataRows = rawTransactions
      .asMap()
      .entries
      .map((entry) {
        final index = entry.key + 1;
        final tx = entry.value;
        return <String>[
          zg('$index'),
          zg(pdfText(tx['customerName'] as String?, maxChars: 20)),
          zg(pdfText(tx['phone'] as String, maxChars: 16)),
          zg(pdfText(tx['parcelType'] as String, maxChars: 18)),
          zg(pdfText(tx['number'] as String, maxChars: 10)),
          zg(tx['charges'] as String),
          zg(tx['paymentStatus'] as String),
          zg(tx['cashAdvance'] as String),
          zg(''),
          zg(pdfText(tx['comment'] as String?, maxChars: 24)),
        ];
      })
      .toList(growable: false);

  List<List<String>> summaryRows() {
    final rows = <List<String>>[];

    void addAmountRow(String label, double amount, {bool deduction = false}) {
      rows.add([
        zg(''),
        zg(label),
        zg(''),
        zg(''),
        zg(''),
        zg(deduction ? '- ${Format.money(amount)}' : Format.money(amount)),
        zg(''),
        zg(''),
        zg(''),
        zg(''),
      ]);
    }

    addAmountRow('Total Charges', totalCharges);
    if (totalChargesPaid > 0) {
      addAmountRow(AppString.paymentPaid, totalChargesPaid, deduction: true);
    }
    addAmountRow(AppString.paymentPending, totalChargesPending);
    if (totalCashAdvance > 0) {
      addAmountRow(AppString.colCashAdvance, totalCashAdvance);
    }

    void addDeductionRow(String label, double amount) {
      if (amount <= 0) return;
      addAmountRow(label, amount, deduction: true);
    }

    addDeductionRow('Room Fee', roomFeeValue);
    addDeductionRow('Labor Fee', laborFeeValue);
    addDeductionRow('Delivery Fee', deliveryFeeValue);

    rows.addAll([
      [
        zg(''),
        zg('Paid Out Amount'),
        zg(''),
        zg(''),
        zg(''),
        zg(Format.money(netAmount)),
        zg(''),
        zg(''),
        zg(''),
        zg(''),
      ],
      [
        zg(''),
        zg(AppString.paidOutStatusLabel),
        zg(
          paidOut
              ? AppString.paidOutStatusPaidMm
              : AppString.paidOutStatusPendingMm,
        ),
        zg(''),
        zg(''),
        zg(''),
        zg(''),
        zg(''),
        zg(''),
        zg(''),
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
  ].map(zg).toList(growable: false);

  const chunkSize = 13;
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
    dataChunks.add(<List<String>>[]);
  }
  final summary = summaryRows();

  for (var i = 0; i < dataChunks.length; i++) {
    final chunk = List<List<String>>.from(dataChunks[i]);
    final isLast = i == dataChunks.length - 1;
    if (isLast) {
      chunk.addAll(summary);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(Dimens.spacingXL),
        theme: pdfTheme,
        maxPages: 100,
        build: (context) => [
          pw.Text(zg('Incoming Parcel Slip'), style: headerStyle),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  zg('Driver: ${pdfText(driverName, maxChars: 24)}'),
                  style: subtitleStyle,
                ),
              ),
              pw.Text(zg('Date: $driverDate'), style: subtitleStyle),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: chunk,
            headerStyle: bold,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
                zg('Continued on next page...'),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            zg('Page ${i + 1} / ${dataChunks.length}'),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ),
    );
  }

  return doc.save();
}

class DriverPrintController extends GetxController {
  DriverPrintController(this.driverId);

  final int driverId;
  final AppDatabase _db = AppDatabase();

  final RxBool isLoading = true.obs;
  final RxBool isPrinting = false.obs;
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
  bool _syncingFeeFields = false;

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
    if (_syncingFeeFields) return;
    roomFee.value = _parse(roomFeeCtrl.text);
    laborFee.value = _parse(laborFeeCtrl.text);
    deliveryFee.value = _parse(deliveryFeeCtrl.text);
  }

  double _parse(String value) {
    return MoneyInput.parseOptionalKyatAsDouble(value);
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final d = await _db.getDriverById(driverId);
      driver.value = d;
      if (d != null) {
        final txs = await _db.getTransactionsByDriver(driverId);
        transactions.assignAll(txs);
        _syncFeeFieldsFromDriver(d);
        paidOut.value = d.paidOut;
      } else {
        transactions.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _syncFeeFieldsFromDriver(Driver currentDriver) {
    _syncingFeeFields = true;
    try {
      roomFee.value = currentDriver.roomFee ?? 0;
      laborFee.value = currentDriver.laborFee ?? 0;
      deliveryFee.value = currentDriver.deliveryFee ?? 0;
      roomFeeCtrl.text = MoneyInput.formatInitial(roomFee.value);
      laborFeeCtrl.text = MoneyInput.formatInitial(laborFee.value);
      deliveryFeeCtrl.text = MoneyInput.formatInitial(deliveryFee.value);
    } finally {
      _syncingFeeFields = false;
    }
  }

  PayoutBreakdown get payoutBreakdown {
    final currentDriver = driver.value;
    return PayoutCalculator.forDriver(
      currentDriver ??
          Driver(
            id: driverId,
            date: DateTime.now(),
            name: '',
            paidOut: paidOut.value,
          ),
      transactions,
      roomFee: roomFeeValue,
      laborFee: laborFeeValue,
      deliveryFee: deliveryFeeValue,
      paidOut: paidOut.value,
    );
  }

  double get totalChargesPending => payoutBreakdown.paymentPending;

  double get totalCharges => payoutBreakdown.totalCharges;

  double get totalChargesPaid => payoutBreakdown.paymentPaid;

  double get totalCashAdvance => payoutBreakdown.cashAdvance;

  double get roomFeeValue => roomFee.value;
  double get laborFeeValue => laborFee.value;
  double get deliveryFeeValue => deliveryFee.value;

  double get totalDeductions => payoutBreakdown.totalFees;

  double get netAmount => payoutBreakdown.currentPayable;

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
    final paidOutAmount = paidOut.value
        ? (currentDriver.paidOut
              ? currentDriver.paidOutAmount ?? netAmount
              : netAmount)
        : null;
    final paidOutAt = paidOut.value
        ? (currentDriver.paidOut
              ? currentDriver.paidOutAt ?? DateTime.now()
              : DateTime.now())
        : null;

    final updatedDriver = currentDriver.copyWith(
      roomFee: drift.Value(roomFeeValue),
      laborFee: drift.Value(laborFeeValue),
      deliveryFee: drift.Value(deliveryFeeValue),
      paidOut: paidOut.value,
      paidOutAmount: drift.Value(paidOutAmount),
      paidOutAt: drift.Value(paidOutAt),
    );

    await (_db.update(_db.drivers)..where((d) => d.id.equals(driverId))).write(
      DriversCompanion(
        roomFee: drift.Value(roomFeeValue),
        laborFee: drift.Value(laborFeeValue),
        deliveryFee: drift.Value(deliveryFeeValue),
        paidOut: drift.Value(paidOut.value),
        paidOutAmount: drift.Value(paidOutAmount),
        paidOutAt: drift.Value(paidOutAt),
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
    final snapshot = <String, dynamic>{
      'fontBytes': fontData.buffer.asUint8List(),
      'driverName': currentDriver.name,
      'driverDate': Format.date(currentDriver.date),
      'totalCharges': totalCharges,
      'totalChargesPaid': totalChargesPaid,
      'totalChargesPending': totalChargesPending,
      'totalCashAdvance': totalCashAdvance,
      'roomFeeValue': roomFeeValue,
      'laborFeeValue': laborFeeValue,
      'deliveryFeeValue': deliveryFeeValue,
      'netAmount': netAmount,
      'paidOut': paidOut.value,
      'transactions': transactions
          .map(
            (t) => <String, dynamic>{
              'customerName': t.customerName,
              'phone': t.phone,
              'parcelType': t.parcelType,
              'number': t.number,
              'charges': Format.money(t.charges),
              'paymentStatus': t.paymentStatus,
              'cashAdvance': Format.money(t.cashAdvance),
              'comment': t.comment,
            },
          )
          .toList(growable: false),
    };
    return compute(_buildDriverSlipPdf, snapshot);
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
    if (currentDriver == null || isPrinting.value) return;

    _ensureFeeDefaults();
    isPrinting.value = true;
    try {
      final bytes = await _buildPdfBytes(currentDriver);
      if (Platform.isWindows) {
        await _openPdfOnWindows(bytes);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
        );
      }
    } finally {
      isPrinting.value = false;
    }
  }

  void setPaidOut(bool value) {
    paidOut.value = value;
  }
}
