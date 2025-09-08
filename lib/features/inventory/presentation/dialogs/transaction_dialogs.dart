import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/dimens.dart';

Future<void> showEditTransactionDialog(
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
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Phone is required';
                        }
                        return null;
                      },
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Number is required';
                        }
                        return null;
                      },
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
                      keyboardType: const TextInputType.numberWithOptions(
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
                      keyboardType: const TextInputType.numberWithOptions(
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
                        labelText: 'Cash Advance',
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
                  ],
                ),
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
                if (!(formKey.currentState?.validate() ?? false)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Phone or Number is required'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  return;
                }
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

Future<void> showViewTransactionDialog(
  BuildContext context,
  DbTransaction t,
) async {
  String _fmtMoney(double v) {
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  String _fmtDateTime12(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    final h24 = d.hour;
    final ampm = h24 >= 12 ? 'PM' : 'AM';
    final h12 = (h24 % 12 == 0) ? 12 : h24 % 12;
    final hh = h12.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min $ampm';
  }

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Transaction Details'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${t.customerName ?? '-'}'),
              const SizedBox(height: 4),
              Text('Phone: ${t.phone}'),
              const SizedBox(height: 4),
              Text('Parcel Type: ${t.parcelType}'),
              const SizedBox(height: 4),
              Text('Number: ${t.number}'),
              const SizedBox(height: 4),
              Text('Charges: ${_fmtMoney(t.charges)}'),
              const SizedBox(height: 4),
              Text('Cash Advance: ${_fmtMoney(t.cashAdvance)}'),
              const SizedBox(height: 4),
              Text('Payment Status: ${t.paymentStatus}'),
              const SizedBox(height: 4),
              Text('Picked Up: ${t.pickedUp ? 'Yes' : 'No'}'),
              const SizedBox(height: 4),
              Text('Collect Time: ${t.pickedUp ? _fmtDateTime12(t.updatedAt) : '-'}'),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text('Comment:'),
              const SizedBox(height: 4),
              Text(t.comment ?? '-', style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Future<void> showClaimTransactionDialog(
  BuildContext context,
  InventoryController controller,
  DbTransaction t,
) async {
  final commentCtrl = TextEditingController();
  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Claim Transaction'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${t.customerName ?? '-'}'),
              const SizedBox(height: 4),
              Text('Phone: ${t.phone}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
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
              await controller.claimTransaction(
                tx: t,
                comment: commentCtrl.text,
              );
              // ignore: use_build_context_synchronously
              Navigator.of(ctx).pop();
            },
            child: const Text('Claim'),
          ),
        ],
      );
    },
  );
}

Future<bool?> confirmDeleteTransaction(
  BuildContext context,
  DbTransaction t,
) async {
  final controller = TextEditingController();
  String value = '';
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final canDelete = value.trim().toLowerCase() == 'confirm';
          return AlertDialog(
            title: const Text('Delete Transaction?'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will remove the transaction permanently. This cannot be undone.',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction: No ${t.number} — Customer: ${t.customerName ?? '-'}',
                    style: const TextStyle(color: Colors.black54),
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
                    onChanged: (txt) => setState(() => value = txt),
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

Future<void> showAddTransactionDialog(
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
  String paymentStatus = 'ငွေတောင်းရန်';
  const bool pickedUp = false;
  final formKey = GlobalKey<FormState>();

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
                child: Form(
                  key: formKey,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'ဖုန်းနံပါတ် ထည့်ပါ';
                          }
                          return null;
                        },
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Number is required';
                          }
                          return null;
                        },
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
                        keyboardType: const TextInputType.numberWithOptions(
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
                        keyboardType: const TextInputType.numberWithOptions(
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
                    ],
                  ),
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
                  if (!(formKey.currentState?.validate() ?? false)) {
                    Get.snackbar(
                      'Warning',
                      'ဖုန်းနံပါတ် ထည့်ပါ',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(12),
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
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
                  } catch (_) {}
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
