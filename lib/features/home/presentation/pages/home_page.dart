import 'package:fluent_ui/fluent_ui.dart' as fluent;
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
import 'package:tkt_pos/widgets/desktop_form_dialog.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: 'Home',
      subtitle: 'Trip overview and dispatch records',
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
            Expanded(
              child: HeaderSearchField(
                hint: AppString.searchHint,
                onChanged: controller.setSearch,
                borderRadius: BorderRadius.circular(Dimens.radiusXS),
              ),
            ),
            const SizedBox(width: Dimens.spacingMD),
            fluent.FilledButton(
              onPressed: () => _showAddTripMainDialog(context, controller),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: Dimens.spacingXXS),
                  Text('New Trip'),
                ],
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

  try {
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(ctx).pop();
              await controller.addTripMain(
                date: date,
                driverName: nameCtrl.text.trim(),
                carId: carCtrl.text.trim(),
              );
            }

            return DesktopFormDialog(
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: save,
              maxWidth: 720,
              contentWidth: 640,
              title: const Text('New Trip'),
              actions: [
                fluent.Button(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                fluent.FilledButton(onPressed: save, child: const Text('Save')),
              ],
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: DesktopFormSection(
                  title: 'Trip',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: nameCtrl,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Driver Name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: Dimens.spacingSM),
                      Expanded(
                        child: TextFormField(
                          controller: carCtrl,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => save(),
                          decoration: const InputDecoration(
                            labelText: 'Car ID',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: Dimens.spacingSM),
                      SizedBox(
                        width: 180,
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            side: const BorderSide(color: AppColor.border),
                          ),
                          title: const Text('Date'),
                          subtitle: Text(Format.date(date)),
                          trailing: const Icon(Icons.calendar_month_outlined),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => date = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    nameCtrl.dispose();
    carCtrl.dispose();
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 96,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 24,
              color: AppColor.textSecondary,
            ),
            const SizedBox(width: Dimens.spacingSM),
            Text(
              AppString.noTripMainRecords,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColor.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
