import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/home/presentation/controllers/home_controller.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/widgets/page_header.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/app/router/app_pages.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTripMainDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 80,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: AppString.title,
                crumbs: const ['Home'],
                showBack: false,
                trailing: SizedBox(
                  width: 360,
                  child: Row(
                    children: [
                      Expanded(
                        child: HeaderSearchField(
                          hint: AppString.searchHint,
                          onChanged: controller.setSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final rows = controller.items;
                  if (rows.isEmpty) {
                    return const Center(
                      child: Text('No records in Trip Main.'),
                    );
                  }
                  return _TripMainTable(rows: rows);
                }),
              ),
            ],
          ),
          EdgeDrawerOpener(),
        ],
      ),
    );
  }
}

class _TripMainTable extends StatefulWidget {
  const _TripMainTable({required this.rows});
  final List rows;

  @override
  State<_TripMainTable> createState() => _TripMainTableState();
}

class _TripMainTableState extends State<_TripMainTable> {
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
    final rows = widget.rows;
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
                child: DataTable(
                  columnSpacing: 16,
                  horizontalMargin: 12,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Driver Name')),
                    DataColumn(label: Text('Car ID')),
                    DataColumn(label: Text('Commission')),
                    DataColumn(label: Text('Labor Cost')),
                    DataColumn(label: Text('Support Payment')),
                    DataColumn(label: Text('Room Fee')),
                  ],
                  rows: [
                    ...rows.asMap().entries.map((e) {
                      final r = e.value;
                      Widget right(String s) => Align(
                        alignment: Alignment.centerRight,
                        child: Text(s),
                      );
                      return DataRow(
                        onSelectChanged: (selected) {
                          if (selected == true) {
                            Get.toNamed(Routes.tripDetail, arguments: r);
                          }
                        },
                        cells: [
                          DataCell(Text(Format.date(r.date))),
                          DataCell(Text(r.driverName)),
                          DataCell(Text(r.carId)),
                          DataCell(right(Format.money(r.commission ?? 0))),
                          DataCell(right(Format.money(r.laborCost ?? 0))),
                          DataCell(right(Format.money(r.supportPayment ?? 0))),
                          DataCell(right(Format.money(r.roomFee ?? 0))),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _showAddTripMainDialog(
  BuildContext context,
  HomeController controller,
) async {
  final nameCtrl = TextEditingController();
  final carCtrl = TextEditingController();
  DateTime date = DateTime.now();
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('New Trip'),
            content: SizedBox(
              width: 420,
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Driver Name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text('Date: ' + Format.date(date))),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => date = picked);
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: carCtrl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Car ID',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final name = nameCtrl.text.trim();
                  final carId = carCtrl.text.trim();
                  await controller.addTripMain(
                    date: date,
                    driverName: name,
                    carId: carId,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
