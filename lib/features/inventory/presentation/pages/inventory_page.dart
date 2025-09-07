import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/driver_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/transaction_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/search_box.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/transaction_actions_menu.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/driver_actions_menu.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';

class InventoryPage extends GetView<InventoryController> {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Inventory')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDriverDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: Dimens.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBox(controller: controller),
            const SizedBox(height: Dimens.d16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.drivers;
                if (list.isEmpty) {
                  return const Center(
                    child: Text('No drivers yet. Tap + to add.'),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Dimens.d24),
                  itemBuilder: (context, index) {
                    final d = list[index];
                    return _DriverSection(driver: d, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverSection extends StatelessWidget {
  const _DriverSection({required this.driver, required this.controller});
  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(driver.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                dateStr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Text(
                driver.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      showAddTransactionDialog(context, controller, driver.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: Dimens.d8),
                DriverActionsMenu(driver: driver, controller: controller),
              ],
            ),
          ],
        ),
        const SizedBox(height: Dimens.d8),
        _DriverTransactionsTable(controller: controller, driverId: driver.id),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
  }
}

class _DriverTransactionsTable extends StatefulWidget {
  const _DriverTransactionsTable({
    required this.controller,
    required this.driverId,
  });
  final InventoryController controller;
  final int driverId;

  @override
  State<_DriverTransactionsTable> createState() =>
      _DriverTransactionsTableState();
}

class _DriverTransactionsTableState extends State<_DriverTransactionsTable> {
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  String _fmtMoney(double v) {
    final isNegative = v < 0;
    var s = v.abs().toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    final parts = s.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 && parts[1].isNotEmpty
        ? '.${parts[1]}'
        : '';

    String groupThousands(String digits) {
      if (digits.length <= 3) return digits;
      final firstLen = digits.length % 3 == 0 ? 3 : digits.length % 3;
      final buf = StringBuffer();
      buf.write(digits.substring(0, firstLen));
      for (int i = firstLen; i < digits.length; i += 3) {
        buf.write(',');
        buf.write(digits.substring(i, i + 3));
      }
      return buf.toString();
    }

    final withCommas = groupThousands(intPart);
    return (isNegative ? '-' : '') + withCommas + fracPart;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = widget.controller.filteredTransactionsForDriver(
        widget.driverId,
      );
      return Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black12.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final headerStyle = const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            );
            final cellStyle = const TextStyle(color: Colors.black87);
            return Scrollbar(
              controller: _vCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _vCtrl,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 12,
                    columns: [
                      DataColumn(label: Text('No', style: headerStyle)),
                      DataColumn(
                        label: Center(
                          child: Text('Customer Name', style: headerStyle),
                        ),
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
                            child: Text('Number', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.charges,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Charges', style: headerStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: AppTableWidths.paymentStatus,
                          child: Center(
                            child: Text('Payment Status', style: headerStyle),
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
                        label: Center(
                          child: Text('Picked Up', style: headerStyle),
                        ),
                      ),
                      DataColumn(label: Text('Comment', style: headerStyle)),
                      DataColumn(
                        label: Center(
                          child: Text('Actions', style: headerStyle),
                        ),
                      ),
                    ],
                    rows: rows.asMap().entries.map((e) {
                      final idx = e.key + 1;
                      final t = e.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(idx.toString(), style: cellStyle)),
                          DataCell(
                            Text(t.customerName ?? '-', style: cellStyle),
                          ),
                          DataCell(
                            SizedBox(
                              width: AppTableWidths.phone,
                              child: Center(
                                child: Text(
                                  t.phone,
                                  style: cellStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: AppTableWidths.parcelType,
                              child: Center(
                                child: Text(
                                  t.parcelType,
                                  style: cellStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: AppTableWidths.number,
                              child: Center(
                                child: Text(
                                  t.number,
                                  style: cellStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: AppTableWidths.charges,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _fmtMoney(t.charges),
                                  style: cellStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: AppTableWidths.paymentStatus,
                              child: Center(
                                child: Text(
                                  t.paymentStatus,
                                  style: cellStyle,
                                  textAlign: TextAlign.center,
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
                                  _fmtMoney(t.cashAdvance),
                                  style: cellStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Icon(
                                t.pickedUp ? Icons.check : Icons.close,
                                color: t.pickedUp ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          DataCell(Text(t.comment ?? '-', style: cellStyle)),
                          DataCell(
                            TransactionActionsMenu(
                              transaction: t,
                              driverId: widget.driverId,
                              controller: widget.controller,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// moved: SearchBox to widgets/search_box.dart

// moved: TransactionActionsMenu to widgets/transaction_actions_menu.dart

// moved: confirmDeleteTransaction to dialogs/transaction_dialogs.dart

// moved: DriverActionsMenu to widgets/driver_actions_menu.dart

Future<void> _showEditDriverDialog(
  BuildContext context,
  InventoryController controller,
  Driver driver,
) async {
  final nameController = TextEditingController(text: driver.name);
  DateTime date = driver.date;
  final formKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Edit Driver'),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Driver name',
                        hintText: 'e.g. Ko Aung',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (_) {
                              final dd = date.day.toString().padLeft(2, '0');
                              final mm = date.month.toString().padLeft(2, '0');
                              final yyyy = date.year.toString().padLeft(4, '0');
                              return Text('Date: $dd/$mm/$yyyy');
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
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
                          child: const Text('Pick Date'),
                        ),
                      ],
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
                  final name = nameController.text.trim();
                  await controller.updateDriver(
                    id: driver.id,
                    date: date,
                    name: name,
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

Future<bool?> _confirmDeleteDriver(BuildContext context, Driver driver) async {
  final controller = TextEditingController();
  String value = '';
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final canDelete = value.trim().toLowerCase() == 'confirm';
          return AlertDialog(
            title: const Text('Delete Driver?'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will remove driver "${driver.name}" and all of their transactions. This cannot be undone.',
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(ctx).style,
                      children: [
                        const TextSpan(text: 'Type '),
                        TextSpan(
                          text: '"confirm"',
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        ),
                        const TextSpan(text: ' to proceed:'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration:
                        const InputDecoration(
                          border: OutlineInputBorder(),
                        ).copyWith(
                          hintText: 'confirm',
                          hintStyle: TextStyle(
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        ),
                    onChanged: (t) => setState(() => value = t),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canDelete ? () => Navigator.of(ctx).pop(true) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showAddDriverDialog(
  BuildContext context,
  InventoryController controller,
) async {
  final nameController = TextEditingController();
  DateTime date = DateTime.now();
  final formKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Add Driver'),
            content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Driver name',
                      hintText: 'e.g. Ko Aung',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Theme.of(ctx)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(ctx).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(ctx).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (_) {
                            final dd = date.day.toString().padLeft(2, '0');
                            final mm = date.month.toString().padLeft(2, '0');
                            final yyyy = date.year.toString().padLeft(4, '0');
                            return Text('Date: $dd/$mm/$yyyy');
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
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
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                ],
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
                  final name = nameController.text.trim();
                  await controller.addDriver(date: date, name: name);
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

Future<void> _showAddTransactionDialog(
  BuildContext context,
  InventoryController controller,
  int driverId,
) async {
  final customerCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final parcelCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final chargesCtrl = TextEditingController(text: '0');
  final cashAdvanceCtrl = TextEditingController(text: '0');
  // Default states
  String paymentStatus = 'ငွေတောင်းရန်';
  const bool pickedUp = false; // default; no control in form

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Add Transaction'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: customerCtrl,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: parcelCtrl,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Parcel Type',
                        prefixIcon: const Icon(Icons.local_shipping_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: numberCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Number',
                        prefixIcon: const Icon(
                          Icons.confirmation_number_outlined,
                        ),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: chargesCtrl,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Charges',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: paymentStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'ငွေရှင်းပြီး',
                          child: Text('ငွေရှင်းပြီး'),
                        ),
                        DropdownMenuItem(
                          value: 'ငွေတောင်းရန်',
                          child: Text('ငွေတောင်းရန်'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => paymentStatus = v ?? paymentStatus),
                      decoration: InputDecoration(
                        labelText: 'Payment Status',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cashAdvanceCtrl,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Cash Advance (optional)',
                        prefixIcon: const Icon(Icons.savings_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    // Comment removed
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
                  try {
                    final charges =
                        double.tryParse(chargesCtrl.text.trim()) ?? 0;
                    final cashAdvance =
                        double.tryParse(cashAdvanceCtrl.text.trim()) ?? 0.0;
                    await controller.addTransaction(
                      driverId: driverId,
                      customerName: customerCtrl.text.trim().isEmpty
                          ? null
                          : customerCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      parcelType: parcelCtrl.text.trim(),
                      number: numberCtrl.text.trim(),
                      charges: charges,
                      paymentStatus: paymentStatus,
                      cashAdvance: cashAdvance,
                      pickedUp: pickedUp,
                      comment: null,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(ctx).pop();
                  } catch (_) {
                    // simple guard; you can add validation
                  }
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
