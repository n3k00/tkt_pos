import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
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
        onPressed: () => _showAddDriverDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBox(controller: controller),
            const SizedBox(height: 16),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
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
                      _showAddTransactionDialog(context, controller, driver.id),
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
                const SizedBox(width: 8),
                _DriverActionsMenu(driver: driver, controller: controller),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
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
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
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
        child: SizedBox(
          height: 240,
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
                              _TransactionActionsMenu(
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
        ),
      );
    });
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller});
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Search',
        hintText: 'Type to filter transactions...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: controller.setSearch,
    );
  }
}

class _TransactionActionsMenu extends StatelessWidget {
  const _TransactionActionsMenu({
    required this.transaction,
    required this.driverId,
    required this.controller,
  });
  final DbTransaction transaction;
  final int driverId;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Transaction actions',
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await _showEditTransactionDialog(
              context,
              controller,
              driverId,
              transaction,
            );
            break;
          case 'delete':
            final ok = await _confirmDeleteTransaction(context);
            if (ok == true) {
              await controller.db.deleteTransactionById(transaction.id);
              await controller.loadTransactionsByDriverToMap(driverId);
            }
            break;
        }
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}

Future<bool?> _confirmDeleteTransaction(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Transaction?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

Future<void> _showEditTransactionDialog(
  BuildContext context,
  InventoryController controller,
  int driverId,
  DbTransaction t,
) async {
  final customerCtrl = TextEditingController(text: t.customerName ?? '');
  final phoneCtrl = TextEditingController(text: t.phone);
  final parcelCtrl = TextEditingController(text: t.parcelType);
  final numberCtrl = TextEditingController(text: t.number);
  final chargesCtrl = TextEditingController(text: t.charges.toString());
  final cashAdvanceCtrl = TextEditingController(text: t.cashAdvance.toString());
  String paymentStatus = t.paymentStatus;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: customerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                    ),
                  ),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextFormField(
                    controller: parcelCtrl,
                    decoration: const InputDecoration(labelText: 'Parcel Type'),
                  ),
                  TextFormField(
                    controller: numberCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Number'),
                  ),
                  TextFormField(
                    controller: chargesCtrl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                    ],
                    decoration: const InputDecoration(labelText: 'Charges'),
                  ),
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
                    decoration: const InputDecoration(
                      labelText: 'Payment Status',
                    ),
                  ),
                  TextFormField(
                    controller: cashAdvanceCtrl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Cash Advance',
                    ),
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
                final charges = double.tryParse(chargesCtrl.text.trim()) ?? 0.0;
                final cashAdvance =
                    double.tryParse(cashAdvanceCtrl.text.trim()) ?? 0.0;
                await controller.updateTransaction(
                  TransactionsCompanion(
                    id: drift.Value(t.id),
                    customerName: drift.Value(
                      customerCtrl.text.trim().isEmpty
                          ? null
                          : customerCtrl.text.trim(),
                    ),
                    phone: drift.Value(phoneCtrl.text.trim()),
                    parcelType: drift.Value(parcelCtrl.text.trim()),
                    number: drift.Value(numberCtrl.text.trim()),
                    charges: drift.Value(charges),
                    paymentStatus: drift.Value(paymentStatus),
                    cashAdvance: drift.Value(cashAdvance),
                    pickedUp: drift.Value(t.pickedUp),
                    comment: const drift.Value.absent(),
                    driverId: drift.Value(t.driverId),
                  ),
                );
                // ignore: use_build_context_synchronously
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}

class _DriverActionsMenu extends StatelessWidget {
  const _DriverActionsMenu({required this.driver, required this.controller});
  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More actions',
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await _showEditDriverDialog(context, controller, driver);
            break;
          case 'delete':
            final confirmed = await _confirmDeleteDriver(context, driver);
            if (confirmed == true) {
              await controller.deleteDriver(driver.id);
            }
            break;
        }
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}

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
                  const Text('Type "confirm" to proceed:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'confirm',
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
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
