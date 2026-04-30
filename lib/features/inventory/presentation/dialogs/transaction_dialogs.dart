import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/app_snackbar.dart';

Future<void> showEditTransactionDialog(
  BuildContext context,
  InventoryController controller,
  int driverId,
  DbTransaction t,
) async {
  await showDialog(
    context: context,
    builder: (_) =>
        _EditTransactionDialog(controller: controller, transaction: t),
  );
}

class _EditTransactionDialog extends StatefulWidget {
  const _EditTransactionDialog({
    required this.controller,
    required this.transaction,
  });

  final InventoryController controller;
  final DbTransaction transaction;

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _parcelCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _chargesCtrl;
  late final TextEditingController _cashAdvanceCtrl;
  late String _paymentStatus;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _customerCtrl = TextEditingController(text: t.customerName ?? '');
    _phoneCtrl = TextEditingController(text: t.phone);
    _parcelCtrl = TextEditingController(text: t.parcelType);
    _numberCtrl = TextEditingController(text: t.number);
    _chargesCtrl = TextEditingController(text: t.charges.toString());
    _cashAdvanceCtrl = TextEditingController(text: t.cashAdvance.toString());
    _paymentStatus = t.paymentStatus;
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    _parcelCtrl.dispose();
    _numberCtrl.dispose();
    _chargesCtrl.dispose();
    _cashAdvanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackBars.show(
        context,
        title: AppString.dialogWarning,
        message: AppString.dialogPhoneOrNumberRequired,
        type: AppSnackbarType.warning,
      );
      return;
    }

    try {
      final t = widget.transaction;
      await widget.controller.updateTransaction(
        TransactionsCompanion(
          id: drift.Value(t.id),
          customerName: drift.Value(_nullableTrimmed(_customerCtrl.text)),
          phone: drift.Value(_phoneCtrl.text.trim()),
          parcelType: drift.Value(_parcelCtrl.text.trim()),
          number: drift.Value(_numberCtrl.text.trim()),
          charges: drift.Value(_parseMoney(_chargesCtrl.text)),
          paymentStatus: drift.Value(_paymentStatus),
          cashAdvance: drift.Value(_parseMoney(_cashAdvanceCtrl.text)),
          pickedUp: drift.Value(t.pickedUp),
          comment: const drift.Value.absent(),
          driverId: drift.Value(t.driverId),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBars.show(
        context,
        message: AppString.snackbarTransactionUpdateFailed('$e'),
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppString.dialogEditTransaction),
      content: _TransactionFormBody(
        formKey: _formKey,
        customerCtrl: _customerCtrl,
        phoneCtrl: _phoneCtrl,
        parcelCtrl: _parcelCtrl,
        numberCtrl: _numberCtrl,
        chargesCtrl: _chargesCtrl,
        cashAdvanceCtrl: _cashAdvanceCtrl,
        paymentStatus: _paymentStatus,
        cashAdvanceLabel: AppString.colCashAdvance,
        phoneRequiredMessage: AppString.dialogPhoneRequired,
        onPaymentStatusChanged: (value) => setState(() {
          _paymentStatus = value ?? _paymentStatus;
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppString.dialogCancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text(AppString.dialogSave),
        ),
      ],
    );
  }
}

class _TransactionFormBody extends StatelessWidget {
  const _TransactionFormBody({
    required this.formKey,
    required this.customerCtrl,
    required this.phoneCtrl,
    required this.parcelCtrl,
    required this.numberCtrl,
    required this.chargesCtrl,
    required this.cashAdvanceCtrl,
    required this.paymentStatus,
    required this.cashAdvanceLabel,
    required this.phoneRequiredMessage,
    required this.onPaymentStatusChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController customerCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController parcelCtrl;
  final TextEditingController numberCtrl;
  final TextEditingController chargesCtrl;
  final TextEditingController cashAdvanceCtrl;
  final String paymentStatus;
  final String cashAdvanceLabel;
  final String phoneRequiredMessage;
  final ValueChanged<String?> onPaymentStatusChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTextField(
                controller: customerCtrl,
                labelText: AppString.colCustomerName,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: Dimens.spacingSM),
              _DialogTextField(
                controller: phoneCtrl,
                labelText: AppString.colPhone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => _requiredValidator(v, phoneRequiredMessage),
              ),
              const SizedBox(height: Dimens.spacingSM),
              _DialogTextField(
                controller: parcelCtrl,
                labelText: AppString.colParcelType,
                prefixIcon: Icons.local_shipping_outlined,
              ),
              const SizedBox(height: Dimens.spacingSM),
              _DialogTextField(
                controller: numberCtrl,
                labelText: AppString.colNumber,
                prefixIcon: Icons.confirmation_number_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => _requiredValidator(v, 'Number is required'),
              ),
              const SizedBox(height: Dimens.spacingSM),
              _DialogTextField(
                controller: chargesCtrl,
                labelText: AppString.colCharges,
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                ],
              ),
              const SizedBox(height: Dimens.spacingSM),
              DropdownButtonFormField<String>(
                initialValue: paymentStatus,
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
                onChanged: onPaymentStatusChanged,
                decoration: _dialogInputDecoration(
                  context,
                  labelText: AppString.colPaymentStatus,
                  prefixIcon: Icons.payments_outlined,
                  contentPadding: Dimens.inputPadding14,
                ),
              ),
              const SizedBox(height: Dimens.spacingSM),
              _DialogTextField(
                controller: cashAdvanceCtrl,
                labelText: cashAdvanceLabel,
                prefixIcon: Icons.savings_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: validator == null
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction,
      validator: validator,
      style: const TextStyle(
        fontSize: Dimens.fontSizeSubtitle,
        height: 1.4,
        color: AppColor.textPrimary,
      ),
      decoration: _dialogInputDecoration(
        context,
        labelText: labelText,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

InputDecoration _dialogInputDecoration(
  BuildContext context, {
  required String labelText,
  required IconData prefixIcon,
  EdgeInsetsGeometry contentPadding = Dimens.inputPadding16,
}) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: Icon(prefixIcon),
    filled: true,
    fillColor: Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
    border: OutlineInputBorder(borderRadius: Dimens.borderRadiusInput),
    enabledBorder: OutlineInputBorder(
      borderRadius: Dimens.borderRadiusInput,
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: Dimens.borderRadiusInput,
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    ),
    isDense: true,
    contentPadding: contentPadding,
  );
}

String? _requiredValidator(String? value, String message) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? _nullableTrimmed(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double _parseMoney(String value) => double.tryParse(value.trim()) ?? 0.0;

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
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest
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
                    (t.comment?.trim().isNotEmpty ?? false) ? t.comment! : '-',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColor.textPrimary,
                    ),
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
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(ctx).pop(),
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
                            if (ctx.mounted) {
                              setState(() => isSubmitting = false);
                            }
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
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? '-' : value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogWarningBanner extends StatelessWidget {
  const _DialogWarningBanner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.spacingSM),
      decoration: BoxDecoration(
        color: AppColor.warning.withValues(alpha: 0.18),
        borderRadius: Dimens.borderRadiusInput,
        border: Border.all(color: AppColor.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColor.warning),
          const SizedBox(width: Dimens.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColor.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Dimens.spacingXXS),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColor.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  const _DialogWarningBanner(
                    title: AppString.dialogWarning,
                    message: AppString.dialogDeleteWarning,
                  ),
                  const SizedBox(height: Dimens.spacingSM),
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
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _AddTransactionDialog(controller: controller, driverId: driverId),
  );
}

class _AddTransactionDialog extends StatefulWidget {
  const _AddTransactionDialog({
    required this.controller,
    required this.driverId,
  });

  final InventoryController controller;
  final int driverId;

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _parcelCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _chargesCtrl = TextEditingController(text: '0');
  final _cashAdvanceCtrl = TextEditingController(text: '0');
  String _paymentStatus = AppString.paymentPending;

  @override
  void dispose() {
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    _parcelCtrl.dispose();
    _numberCtrl.dispose();
    _chargesCtrl.dispose();
    _cashAdvanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackBars.show(
        context,
        title: AppString.dialogWarning,
        message: AppString.snackbarClaimValidation,
        type: AppSnackbarType.warning,
      );
      return;
    }

    try {
      await widget.controller.addTransaction(
        driverId: widget.driverId,
        customerName: _nullableTrimmed(_customerCtrl.text),
        phone: _phoneCtrl.text.trim(),
        parcelType: _parcelCtrl.text.trim(),
        number: _numberCtrl.text.trim(),
        charges: _parseMoney(_chargesCtrl.text),
        paymentStatus: _paymentStatus,
        cashAdvance: _parseMoney(_cashAdvanceCtrl.text),
        pickedUp: false,
        comment: null,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBars.show(
        context,
        message: AppString.snackbarTransactionAddFailed('$e'),
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text(AppString.dialogAddTransaction),
        content: _TransactionFormBody(
          formKey: _formKey,
          customerCtrl: _customerCtrl,
          phoneCtrl: _phoneCtrl,
          parcelCtrl: _parcelCtrl,
          numberCtrl: _numberCtrl,
          chargesCtrl: _chargesCtrl,
          cashAdvanceCtrl: _cashAdvanceCtrl,
          paymentStatus: _paymentStatus,
          cashAdvanceLabel: AppString.dialogCashAdvanceOptional,
          phoneRequiredMessage: 'ဖုန်းနံပါတ် ထည့်ပါ',
          onPaymentStatusChanged: (value) => setState(() {
            _paymentStatus = value ?? _paymentStatus;
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppString.dialogCancel),
          ),
          ElevatedButton(
            onPressed: _save,
            child: const Text(AppString.dialogSave),
          ),
        ],
      ),
    );
  }
}
