import 'dart:convert';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/format.dart';

enum ReportGroupMode { driver, paymentStatus }

class ReportsController extends GetxController {
  final AppDatabase db = AppDatabase();

  final RxInt currentTabIndex = 0.obs; // legacy
  final RxString search = ''.obs;
  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());
  final Rx<DateTime> startDate = Rx<DateTime>(_dayStart(DateTime.now()));
  final Rx<DateTime> endDate = Rx<DateTime>(_dayStart(DateTime.now()));
  final Rx<ReportGroupMode> groupMode = ReportGroupMode.driver.obs;
  final RxList<DbTransaction> all = <DbTransaction>[].obs;
  final RxMap<int, Driver> driverMap = <int, Driver>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final start = _dayStart(startDate.value);
    final end = _dayStart(endDate.value).add(const Duration(days: 1));
    var list = await db.getReportedTransactions(start, end);
    if (list.isEmpty) {
      // Backfill once for this day from picked-up transactions, then reload
      await _backfillRange(start, end);
      list = await db.getReportedTransactions(start, end);
    }
    all.assignAll(list);

    // fetch driver names for displayed rows in one query
    if (all.isEmpty) {
      driverMap.clear();
      update();
      return;
    }
    final ids = all.map((e) => e.driverId).toSet().toList();
    final ds = await (db.select(
      db.drivers,
    )..where((d) => d.id.isIn(ids))).get();
    driverMap.assignAll({for (final d in ds) d.id: d});
    update();
  }

  void setTab(int index) {
    currentTabIndex.value = index;
  }

  void setSearch(String v) => search.value = v;
  void setDate(DateTime d) {
    selectedDate.value = d;
    startDate.value = _dayStart(d);
    endDate.value = _dayStart(d);
    load();
  }

  void setDateRange(DateTime start, DateTime end) {
    final normalizedStart = _dayStart(start);
    final normalizedEnd = _dayStart(end);
    startDate.value = normalizedStart;
    endDate.value = normalizedEnd.isBefore(normalizedStart)
        ? normalizedStart
        : normalizedEnd;
    selectedDate.value = startDate.value;
    load();
  }

  void setPresetToday() {
    final today = _dayStart(DateTime.now());
    setDateRange(today, today);
  }

  void setPresetYesterday() {
    final yesterday = _dayStart(
      DateTime.now(),
    ).subtract(const Duration(days: 1));
    setDateRange(yesterday, yesterday);
  }

  void setPresetThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final end = DateTime(
      now.year,
      now.month + 1,
    ).subtract(const Duration(days: 1));
    setDateRange(start, end);
  }

  void setGroupMode(ReportGroupMode mode) => groupMode.value = mode;

  List<DbTransaction> get filtered {
    final q = search.value.trim().toLowerCase();
    final src = all;

    if (q.isEmpty) return src;
    return src
        .where((t) {
          final f = <String?>[
            t.customerName,
            t.phone,
            t.parcelType,
            t.number,
            t.paymentStatus,
            driverNameFor(t.driverId),
          ];
          return f.any((s) => (s ?? '').toLowerCase().contains(q));
        })
        .toList(growable: false);
  }

  double get totalChargesAll => filtered.fold(0.0, (s, t) => s + t.charges);
  double get totalChargesPending => filtered
      .where((t) => _isPending(t.paymentStatus))
      .fold(0.0, (s, t) => s + t.charges);
  double get totalChargesPaid => filtered
      .where((t) => _isPaid(t.paymentStatus))
      .fold(0.0, (s, t) => s + t.charges);
  double get totalCashAdvance =>
      filtered.fold(0.0, (s, t) => s + t.cashAdvance);
  double get totalChargesCombined =>
      totalChargesPending + totalChargesPaid + totalCashAdvance;
  // For Total Charges card: Pending + Cash Advance only (exclude Paid)
  double get totalChargesPendingAndAdvance =>
      totalChargesPending + totalCashAdvance;
  int get totalCount => filtered.length;

  String driverNameFor(int driverId) => driverMap[driverId]?.name ?? '-';

  List<ReportGroupSummary> get groupedSummaries {
    final totals = <String, ReportGroupSummary>{};
    for (final t in filtered) {
      final key = groupMode.value == ReportGroupMode.driver
          ? driverNameFor(t.driverId)
          : t.paymentStatus;
      final current = totals[key];
      if (current == null) {
        totals[key] = ReportGroupSummary(
          label: key,
          count: 1,
          charges: t.charges,
          cashAdvance: t.cashAdvance,
        );
      } else {
        totals[key] = current.copyWith(
          count: current.count + 1,
          charges: current.charges + t.charges,
          cashAdvance: current.cashAdvance + t.cashAdvance,
        );
      }
    }
    final summaries = totals.values.toList();
    summaries.sort((a, b) => b.total.compareTo(a.total));
    return summaries;
  }

  Future<String?> exportCsv() async {
    final location = await fs.getSaveLocation(
      suggestedName: 'tkt-pos-report-${_rangeFileStamp()}.csv',
      acceptedTypeGroups: const [
        fs.XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (location == null) return null;

    final buffer = StringBuffer();
    buffer.writeln(
      [
        'No',
        'Driver',
        'Customer',
        'Phone',
        'Parcel',
        'Number',
        'Charges',
        'Payment Status',
        'Cash Advance',
        'Comment',
      ].map(_csv).join(','),
    );
    for (final entry in filtered.asMap().entries) {
      final t = entry.value;
      buffer.writeln(
        [
          '${entry.key + 1}',
          driverNameFor(t.driverId),
          t.customerName ?? '-',
          t.phone,
          t.parcelType,
          t.number,
          t.charges.toStringAsFixed(0),
          t.paymentStatus,
          t.cashAdvance.toStringAsFixed(0),
          t.comment ?? '-',
        ].map(_csv).join(','),
      );
    }
    await fs.XFile.fromData(
      utf8.encode(buffer.toString()),
      mimeType: 'text/csv',
      name: 'report.csv',
    ).saveTo(location.path);
    return location.path;
  }

  Future<void> printReport() async {
    final doc = pw.Document();
    final fontData = await rootBundle.load(
      'assets/fonts/Pyidaungsu_Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final rows = filtered;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => [
          pw.Text(
            'TKT POS Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Period: ${rangeLabel()}'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFECEFF3),
            ),
            headers: const [
              'No',
              'Driver',
              'Customer',
              'Phone',
              'Parcel',
              'No.',
              'Charges',
              'Status',
              'Cash Adv.',
            ],
            data: [
              for (final entry in rows.asMap().entries)
                [
                  '${entry.key + 1}',
                  driverNameFor(entry.value.driverId),
                  entry.value.customerName ?? '-',
                  entry.value.phone,
                  entry.value.parcelType,
                  entry.value.number,
                  Format.money(entry.value.charges),
                  entry.value.paymentStatus,
                  Format.money(entry.value.cashAdvance),
                ],
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total: ${Format.money(totalChargesPendingAndAdvance)}   Paid: ${Format.money(totalChargesPaid)}   Cash advance: ${Format.money(totalCashAdvance)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  String rangeLabel() {
    if (_isSameDay(startDate.value, endDate.value)) {
      return _formatDate(startDate.value);
    }
    return '${_formatDate(startDate.value)} - ${_formatDate(endDate.value)}';
  }

  Future<void> _backfillRange(DateTime start, DateTime exclusiveEnd) async {
    var cursor = start;
    while (cursor.isBefore(exclusiveEnd)) {
      await db.backfillReportTransactionsForDay(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  bool _isPending(String status) {
    final s = status.trim();
    // Support multiple encodings / fallbacks
    if (s.toLowerCase() == 'pending') return true;
    // AppString constant (may differ by encoding on some setups)
    if (s == AppString.paymentPending) return true;
    return false;
  }

  bool _isPaid(String status) {
    final s = status.trim();
    if (s.toLowerCase() == 'paid') return true;
    if (s == AppString.paymentPaid) return true;
    if (s == AppString.paymentPaidAltMm) {
      return true; // alternative MM wording commonly used
    }
    return false;
  }

  String _rangeFileStamp() {
    final start = _fileDate(startDate.value);
    final end = _fileDate(endDate.value);
    return start == end ? start : '$start-$end';
  }
}

class ReportGroupSummary {
  const ReportGroupSummary({
    required this.label,
    required this.count,
    required this.charges,
    required this.cashAdvance,
  });

  final String label;
  final int count;
  final double charges;
  final double cashAdvance;

  double get total => charges + cashAdvance;

  ReportGroupSummary copyWith({
    String? label,
    int? count,
    double? charges,
    double? cashAdvance,
  }) {
    return ReportGroupSummary(
      label: label ?? this.label,
      count: count ?? this.count,
      charges: charges ?? this.charges,
      cashAdvance: cashAdvance ?? this.cashAdvance,
    );
  }
}

DateTime _dayStart(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}

String _fileDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$yyyy$mm$dd';
}

String _csv(String value) => '"${value.replaceAll('"', '""')}"';
