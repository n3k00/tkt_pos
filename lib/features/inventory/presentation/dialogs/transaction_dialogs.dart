import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/resources/strings.dart';

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
          title: const Text(AppString.dialogEditTransaction),
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
                        fontSize: Dimens.fontSizeSubtitle,
                        height: 1.4,
                        color: AppColor.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.colCustomerName,
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingSM),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppString.dialogPhoneRequired;
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeSubtitle,
                        height: 1.4,
                        color: AppColor.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.colPhone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingSM),
                    TextFormField(
                      controller: parcelCtrl,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeSubtitle,
                        height: 1.4,
                        color: AppColor.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.colParcelType,
                        prefixIcon: const Icon(Icons.local_shipping_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingSM),
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
                        fontSize: Dimens.fontSizeSubtitle,
                        height: 1.4,
                        color: AppColor.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.colNumber,
                        prefixIcon: const Icon(
                          Icons.confirmation_number_outlined,
                        ),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingSM),
                    TextFormField(
                      controller: chargesCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                      ],
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeSubtitle,
                        height: 1.4,
                        color: AppColor.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.colCharges,
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding16,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingSM),
                DropdownButtonFormField<String>(
                  value: paymentStatus,
                  items: const [
                    DropdownMenuItem(
                      value: AppString.paymentPaid,
                      child: Text(AppString.paymentPaid),
                        ),
                        DropdownMenuItem(
                          value: AppString.paymentPending,
                          child: Text(AppString.paymentPending),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => paymentStatus = v ?? paymentStatus),
                      decoration: InputDecoration(
                        labelText: AppString.colPaymentStatus,
                        prefixIcon: const Icon(Icons.payments_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: Dimens.inputPadding14,
                      ),
                    ),
                    const SizedBox(height: Dimens.spacingSM),
                    TextFormField(
                      controller: cashAdvanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                      ],
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeSubtitle,
                        height: 1.4,
                        color: AppColor.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.colCashAdvance,
                        prefixIcon: const Icon(Icons.savings_outlined),
                        filled: true,
                        fillColor: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
                          borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Dimens.borderRadiusInput,
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
              child: const Text(AppString.dialogCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(AppString.dialogPhoneOrNumberRequired),
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
              child: const Text(AppString.dialogSave),
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
  String fmtMoney(double v) => Format.money(v);
  String fmtDateTime12(DateTime d) => Format.dateTime12(d);

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text(AppString.dialogTransactionDetails),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.spacingMD),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: Dimens.borderRadiusInput,
                    border: Border.all(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      _ClaimInfoRow(
                        icon: Icons.person_outline,
                        label: 'Customer',
                        value: t.customerName?.trim().isEmpty ?? true
                            ? '-'
                            : t.customerName!,
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.phone_outlined,
                        label: AppString.colPhone,
                        value: t.phone,
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.inventory_2_outlined,
                        label: AppString.colParcelType,
                        value: t.parcelType,
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.numbers,
                        label: AppString.colNumber,
                        value: t.number,
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.attach_money,
                        label: AppString.colCharges,
                        value: fmtMoney(t.charges),
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: AppString.colCashAdvance,
                        value: fmtMoney(t.cashAdvance),
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.payments_outlined,
                        label: AppString.colPaymentStatus,
                        value: t.paymentStatus,
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.check_circle_outline,
                      label: AppString.dialogPickedUp,
                        value: t.pickedUp ? 'Yes' : 'No',
                      ),
                      const SizedBox(height: Dimens.spacingXSPlus),
                      _ClaimInfoRow(
                        icon: Icons.schedule,
                        label: 'Collect Time',
                        value: t.pickedUp ? fmtDateTime12(t.updatedAt) : '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimens.spacingMD),
                Text(
                  AppString.dialogComment,
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                const SizedBox(height: Dimens.spacingMicro),
                Container(
                  padding: const EdgeInsets.all(Dimens.spacingSM),
                  decoration: BoxDecoration(
                    borderRadius: Dimens.borderRadiusInput,
                    border: Border.all(color: Theme.of(ctx).dividerColor),
                  ),
                  child: Text(
                    (t.comment?.trim().isNotEmpty ?? false)
                        ? t.comment!
                        : '-',
                    style: Theme.of(ctx)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColor.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppString.dialogClose),
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
  final formKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      bool isSubmitting = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text(AppString.dialogClaimTransaction),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Dimens.spacingSM),
                        decoration: BoxDecoration(
                          color: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: Dimens.borderRadiusInput,
                          border: Border.all(
                            color: Theme.of(ctx).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ClaimInfoRow(
                              icon: Icons.person_outline,
                              label: 'Customer',
                              value: t.customerName?.trim().isEmpty ?? true
                                  ? '-'
                                  : t.customerName!,
                            ),
                            const SizedBox(height: Dimens.spacingMicro),
                            _ClaimInfoRow(
                              icon: Icons.phone_outlined,
                              label: AppString.colPhone,
                              value: t.phone,
                            ),
                            const SizedBox(height: Dimens.spacingMicro),
                            _ClaimInfoRow(
                              icon: Icons.inventory_2_outlined,
                              label: 'Parcel',
                              value: t.parcelType,
                            ),
                            const SizedBox(height: Dimens.spacingMicro),
                            _ClaimInfoRow(
                              icon: Icons.numbers,
                              label: AppString.colNumber,
                              value: t.number,
                            ),
                            const SizedBox(height: Dimens.spacingMicro),
                            _ClaimInfoRow(
                              icon: Icons.attach_money,
                              label: AppString.colCharges,
                              value: Format.money(t.charges),
                            ),
                            const SizedBox(height: Dimens.spacingMicro),
                            _ClaimInfoRow(
                              icon: Icons.payments_outlined,
                              label: AppString.colPaymentStatus,
                              value: t.paymentStatus,
                            ),
                            const SizedBox(height: Dimens.spacingMicro),
                            _ClaimInfoRow(
                              icon: Icons.account_balance_wallet_outlined,
                              label: AppString.colCashAdvance,
                              value: Format.money(t.cashAdvance),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingMD),
                      TextFormField(
                        controller: commentCtrl,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Comment is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppString.dialogComment,
                          helperText: 'Explain who claimed or any note.',
                          prefixIcon: const Icon(Icons.edit_note_outlined),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text(AppString.dialogCancel),
                ),
                ElevatedButton.icon(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text(AppString.dialogConfirmClaim),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() => isSubmitting = true);
                          try {
                            await controller.claimTransaction(
                              tx: t,
                              comment: commentCtrl.text.trim(),
                            );
                            // ignore: use_build_context_synchronously
                            Navigator.of(ctx).pop();
                          } finally {
                            if (ctx.mounted) setState(() => isSubmitting = false);
                          }
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ClaimInfoRow extends StatelessWidget {
  const _ClaimInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: Dimens.spacingXS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? '-' : value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
            title: const Text(AppString.dialogDeleteTransaction),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will remove the transaction permanently. This cannot be undone.',
                  ),
                  const SizedBox(height: Dimens.spacingXS),
                  Text(
                    'Transaction: No ${t.number} — Customer: ${t.customerName ?? '-'}',
                    style: const TextStyle(color: AppColor.textSecondary),
                  ),
                  const SizedBox(height: Dimens.spacingSM),
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
                  const SizedBox(height: Dimens.spacingXS),
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
                child: const Text(AppString.dialogCancel),
              ),
              ElevatedButton(
                onPressed: canDelete ? () => Navigator.of(ctx).pop(true) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.error,
                  foregroundColor: AppColor.white,
                ),
                child: const Text(AppString.dialogDelete),
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
  String paymentStatus = AppString.paymentPending;
  const bool pickedUp = false;
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    barrierDismissible: false, // prevent closing by tapping outside
    builder: (ctx) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text(AppString.dialogAddTransaction),
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
                          fontSize: Dimens.fontSizeSubtitle,
                          height: 1.4,
                          color: AppColor.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: AppString.colCustomerName,
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: Dimens.inputPadding16,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
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
                          fontSize: Dimens.fontSizeSubtitle,
                          height: 1.4,
                          color: AppColor.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: AppString.colPhone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: Dimens.inputPadding16,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
                      TextFormField(
                        controller: parcelCtrl,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeSubtitle,
                          height: 1.4,
                          color: AppColor.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: AppString.colParcelType,
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: Dimens.inputPadding16,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
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
                          fontSize: Dimens.fontSizeSubtitle,
                          height: 1.4,
                          color: AppColor.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: AppString.colNumber,
                          prefixIcon: const Icon(
                            Icons.confirmation_number_outlined,
                          ),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: Dimens.inputPadding16,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
                      TextFormField(
                        controller: chargesCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeSubtitle,
                          height: 1.4,
                          color: AppColor.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: AppString.colCharges,
                          prefixIcon: const Icon(Icons.attach_money),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: Dimens.inputPadding16,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
                      DropdownButtonFormField<String>(
                        value: paymentStatus,
                        items: const [
                          DropdownMenuItem(
                            value: AppString.paymentPaid,
                            child: Text(AppString.paymentPaid),
                          ),
                          DropdownMenuItem(
                            value: AppString.paymentPending,
                            child: Text(AppString.paymentPending),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => paymentStatus = v ?? paymentStatus),
                        decoration: InputDecoration(
                          labelText: AppString.colPaymentStatus,
                          prefixIcon: const Icon(Icons.payments_outlined),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: Dimens.inputPadding14,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
                      TextFormField(
                        controller: cashAdvanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeSubtitle,
                          height: 1.4,
                          color: AppColor.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: AppString.dialogCashAdvanceOptional,
                          prefixIcon: const Icon(Icons.savings_outlined),
                          filled: true,
                          fillColor: Theme.of(ctx)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          border: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
                            borderSide: BorderSide(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Dimens.borderRadiusInput,
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
                child: const Text(AppString.dialogCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) {
                    Get.snackbar(
                      AppString.dialogWarning,
                      AppString.snackbarClaimValidation,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      colorText: AppColor.white,
                      margin: const EdgeInsets.all(Dimens.spacingSM),
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
                  try {
                    final charges =
                        double.tryParse(chargesCtrl.text.trim()) ?? 0;
                    final cashAdvance =
                        double.tryParse(cashAdvanceCtrl.text.trim()) ?? 0.0;
                    // Close dialog before awaiting to avoid using build context after await
                    Navigator.of(ctx).pop();
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
                  } catch (_) {}
                },
                child: const Text(AppString.dialogSave),
              ),
            ],
          );
          },
        ),
      );
    },
  );
}
