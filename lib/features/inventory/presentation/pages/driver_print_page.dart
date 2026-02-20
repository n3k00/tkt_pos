import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';

class DriverPrintPage extends StatefulWidget {
  const DriverPrintPage({super.key, required this.driverId});
  final int driverId;

  @override
  State<DriverPrintPage> createState() => _DriverPrintPageState();
}

class _DriverPrintPageState extends State<DriverPrintPage> {
  final AppDatabase _db = AppDatabase();
  late Future<_DriverPrintPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DriverPrintPayload> _load() async {
    final driver = await _db.getDriverById(widget.driverId);
    final txs = driver == null
        ? <DbTransaction>[]
        : await _db.getTransactionsByDriver(driver.id);
    return _DriverPrintPayload(driver: driver, transactions: txs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Preview'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.snackbar(
                'Print',
                'Printing workflow coming soon.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text('Print', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<_DriverPrintPayload>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.driver == null) {
            return const Center(child: Text('Driver not found.'));
          }
          final payload = snapshot.data!;
          final driver = payload.driver!;
          final transactions = payload.transactions;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1123, // approx A4 landscape width in px at 96dpi
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incoming Parcel Slip',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Driver: ${driver.name}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              'Date: ${Format.date(driver.date)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AppDataTable(
                          table: DataTable(
                            columnSpacing: 12,
                            headingRowHeight: 40,
                            horizontalMargin: 12,
                            columns: const [
                              DataColumn(label: Text(AppString.colNo)),
                              DataColumn(label: Text(AppString.colCustomerName)),
                              DataColumn(label: Text(AppString.colPhone)),
                              DataColumn(label: Text(AppString.colParcelType)),
                              DataColumn(label: Text(AppString.colNumber)),
                              DataColumn(label: Text(AppString.colCharges)),
                              DataColumn(label: Text(AppString.colPaymentStatus)),
                              DataColumn(label: Text(AppString.colCashAdvance)),
                              DataColumn(label: Text('Signed')),
                              DataColumn(label: Text(AppString.colComment)),
                            ],
                            rows: [
                              ...transactions.asMap().entries.map((e) {
                                final idx = e.key + 1;
                                final t = e.value;
                                return DataRow(
                                  cells: [
                                    DataCell(Text('$idx')),
                                    DataCell(Text(t.customerName ?? '-')),
                                    DataCell(SizedBox(
                                      width: AppTableWidths.phone,
                                      child: Text(
                                        t.phone,
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: AppTableWidths.parcelType,
                                      child: Text(
                                        t.parcelType,
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: AppTableWidths.number,
                                      child: Text(
                                        t.number,
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                                    DataCell(Text(
                                      Format.money(t.charges),
                                      textAlign: TextAlign.right,
                                    )),
                                    DataCell(Text(t.paymentStatus)),
                                    DataCell(Text(Format.money(t.cashAdvance))),
                                    const DataCell(Text('______________')),
                                    DataCell(Text(t.comment ?? '-')),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: AppColor.surfaceBackground,
    );
  }
}

class _DriverPrintPayload {
  _DriverPrintPayload({required this.driver, required this.transactions});
  final Driver? driver;
  final List<DbTransaction> transactions;
}
