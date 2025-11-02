import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/styles.dart';
import 'package:tkt_pos/data/local/tables/trip_main.dart';
import 'package:tkt_pos/data/local/tables/trip_manifests.dart';
import 'package:tkt_pos/features/trips/data/trip_repository.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TripMain trip = Get.arguments as TripMain;
    final repo = TripRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header DataTable showing trip meta as column labels
            _TripHeaderTable(trip: trip),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<TripManifest>>(
                future: repo.getTripManifests(trip.id),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data ?? const [];
                  return _ManifestsTable(items: items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripHeaderTable extends StatelessWidget {
  const _TripHeaderTable({required this.trip});
  final TripMain trip;

  @override
  Widget build(BuildContext context) {
    Text header(String title, String value) => Text(
      '$title  { $value }',
      style: const TextStyle(fontWeight: FontWeight.w700),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTableTheme(
        data: const DataTableThemeData(
          headingRowColor: MaterialStatePropertyAll(Color(0xFFF2F4F7)),
          headingTextStyle: TextStyle(fontWeight: FontWeight.w700),
          dividerThickness: 0.6,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 36,
        ),
        child: DataTable(
          columnSpacing: 24,
          showCheckboxColumn: false,
          columns: [
            DataColumn(
              label: header(
                'Date',
                Format.date(DateTime.fromMillisecondsSinceEpoch(trip.date)),
              ),
            ),
            DataColumn(label: header('Driver Name', trip.driverName)),
            DataColumn(label: header('Car ID', trip.carId)),
          ],
          rows: const <DataRow>[],
        ),
      ),
    );
  }
}

class _ManifestsTable extends StatefulWidget {
  const _ManifestsTable({required this.items});
  final List<TripManifest> items;

  @override
  State<_ManifestsTable> createState() => _ManifestsTableState();
}

class _ManifestsTableState extends State<_ManifestsTable> {
  final ScrollController _vCtrl = ScrollController();
  final ScrollController _hCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.items;
    final headerStyle = AppTextStyles.tableHeader;
    final cellStyle = AppTextStyles.tableCell;
    return Scrollbar(
      controller: _vCtrl,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _vCtrl,
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _hCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Card(
                  color: AppColor.white,
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.black12.withValues(alpha: 0.08),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    columnSpacing: 16,
                    horizontalMargin: 12,
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text('No', style: headerStyle),
                        ),
                      ),
                      DataColumn(label: Text('Customer', style: headerStyle)),
                      DataColumn(
                        label: Text('Delivery City', style: headerStyle),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.phone,
                          child: Center(
                            child: Text('Phone', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.parcelType,
                          child: Center(
                            child: Text('Parcel Type', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.number,
                          child: Center(
                            child: Text('Number of Parcel', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.cashAdvance,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Cash Advance', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.cashAdvance,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Payment Pending', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.cashAdvance,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Payment Paid', style: headerStyle),
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      ...list.asMap().entries.map((e) {
                        final i = e.key + 1;
                        final m = e.value;
                        final zebra = i % 2 == 0;
                        Widget center(String s) => Align(
                          alignment: Alignment.center,
                          child: Text(s, style: cellStyle),
                        );
                        Widget right(String s) => Align(
                          alignment: Alignment.centerRight,
                          child: Text(s, style: cellStyle),
                        );
                        return DataRow(
                          color: AppTableStyles.zebra(i),
                          cells: [
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(i.toString(), style: cellStyle),
                              ),
                            ),
                            DataCell(
                              Text(m.customerName ?? '-', style: cellStyle),
                            ),
                            DataCell(
                              Text(m.deliveryCity ?? '-', style: cellStyle),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.phone,
                                child: Center(
                                  child: Text(m.phone ?? '-', style: cellStyle),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.parcelType,
                                child: Center(
                                  child: Text(m.parcelType, style: cellStyle),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.number,
                                child: Center(
                                  child: Text(
                                    m.numberOfParcel.toString(),
                                    style: cellStyle,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.cashAdvance,
                                child: right(Format.money(m.cashAdvance ?? 0)),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.cashAdvance,
                                child: right(
                                  Format.money(m.paymentPending ?? 0),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.cashAdvance,
                                child: right(Format.money(m.paymentPaid ?? 0)),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (list.isNotEmpty)
                        DataRow(
                          color: const MaterialStatePropertyAll(
                            Color(0xFFF2F4F7),
                          ),
                          cells: [
                            const DataCell(SizedBox()),
                            const DataCell(SizedBox()),
                            const DataCell(SizedBox()),
                            const DataCell(SizedBox()),
                            const DataCell(
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Totals',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.number,
                                child: Center(
                                  child: Text(
                                    list
                                        .fold<int>(
                                          0,
                                          (s, m) => s + m.numberOfParcel,
                                        )
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.cashAdvance,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    Format.money(
                                      list.fold<double>(
                                        0,
                                        (s, m) => s + (m.cashAdvance ?? 0),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.cashAdvance,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    Format.money(
                                      list.fold<double>(
                                        0,
                                        (s, m) => s + (m.paymentPending ?? 0),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: AppTableWidths.cashAdvance,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    Format.money(
                                      list.fold<double>(
                                        0,
                                        (s, m) => s + (m.paymentPaid ?? 0),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
