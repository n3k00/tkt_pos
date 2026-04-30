import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/home/presentation/controllers/home_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/page_header.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/app/router/app_pages.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/widgets/desktop_shell.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: 'Home',
      subtitle: 'Trip overview and dispatch records',
      actions: [
        FilledButton.icon(
          onPressed: () => _showAddTripMainDialog(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('New Trip'),
        ),
      ],
      toolbar: Container(
        height: 64,
        padding: const EdgeInsets.all(Dimens.spacingSM),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
          border: Border.all(color: AppColor.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 360,
              child: HeaderSearchField(
                hint: AppString.searchHint,
                onChanged: controller.setSearch,
                borderRadius: BorderRadius.circular(Dimens.radiusXS),
              ),
            ),
          ],
        ),
      ),
      child: Obx(() {
        final rows = controller.filteredItems;
        if (rows.isEmpty) {
          return const _HomeEmptyState();
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(Dimens.radiusXS),
            border: Border.all(color: AppColor.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimens.spacingMD),
            child: _TripMainTable(rows: rows),
          ),
        );
      }),
    );
  }
}

class _TripMainTable extends StatefulWidget {
  const _TripMainTable({required this.rows});
  final List<TripMain> rows;

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
    return AppDataTable(
      table: DataTable(
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
            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  Get.toNamed(Routes.tripDetail, arguments: r);
                }
              },
              cells: [
                DataCell(
                  Text(
                    Format.date(DateTime.fromMillisecondsSinceEpoch(r.date)),
                  ),
                ),
                DataCell(Text(r.driverName)),
                DataCell(Text(r.carId)),
                DataCell(_right(Format.money(r.commission ?? 0))),
                DataCell(_right(Format.money(r.laborCost ?? 0))),
                DataCell(_right(Format.money(r.supportPayment ?? 0))),
                DataCell(_right(Format.money(r.roomFee ?? 0))),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _right(String s) =>
      Align(alignment: Alignment.centerRight, child: Text(s));
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
                    const SizedBox(height: Dimens.spacingSM),
                    Row(
                      children: [
                        Expanded(child: Text('Date: ${Format.date(date)}')),
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
                    const SizedBox(height: Dimens.spacingSM),
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
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final name = nameCtrl.text.trim();
                  final carId = carCtrl.text.trim();
                  // Close the dialog before awaiting to avoid using context after await
                  Navigator.of(ctx).pop();
                  await controller.addTripMain(
                    date: date,
                    driverName: name,
                    carId: carId,
                  );
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

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(Dimens.radiusXXL),
              border: Border.all(color: AppColor.border),
            ),
            child: const Icon(
              Icons.map_outlined,
              size: 48,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: Dimens.spacingMD),
          Text(
            AppString.noTripMainRecords,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColor.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimens.spacingXS),
          Text(
            'Add your first trip to see summary data here.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColor.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
