import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/utils/money_input.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/app_snackbar.dart';
import 'package:tkt_pos/widgets/desktop_form_dialog.dart';

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
    _chargesCtrl = TextEditingController(
      text: MoneyInput.formatInitial(t.charges),
    );
    _cashAdvanceCtrl = TextEditingController(
      text: MoneyInput.formatInitial(t.cashAdvance),
    );
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
          charges: drift.Value(
            MoneyInput.parseRequiredKyatAsDouble(_chargesCtrl.text),
          ),
          paymentStatus: drift.Value(_paymentStatus),
          cashAdvance: drift.Value(
            MoneyInput.parseOptionalKyatAsDouble(_cashAdvanceCtrl.text),
          ),
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

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return DesktopFormDialog(
      onCancel: _cancel,
      onSubmit: _save,
      title: const Text(AppString.dialogEditTransaction),
      actions: [
        fluent.Button(
          onPressed: _cancel,
          child: const Text(AppString.dialogCancel),
        ),
        fluent.FilledButton(
          onPressed: _save,
          child: const Text(AppString.dialogSave),
        ),
      ],
      child: _TransactionFormBody(
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
        onSubmit: _save,
        onPaymentStatusChanged: (value) => setState(() {
          _paymentStatus = value ?? _paymentStatus;
        }),
      ),
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
    required this.onSubmit,
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
  final VoidCallback onSubmit;
  final ValueChanged<String?> onPaymentStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DesktopFormSection(
            title: 'Customer',
            child: Row(
              children: [
                Expanded(
                  child: _DialogTextField(
                    controller: customerCtrl,
                    labelText: AppString.colCustomerName,
                    prefixIcon: Icons.person_outline,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: Dimens.spacingSM),
                Expanded(
                  child: _DialogTextField(
                    controller: phoneCtrl,
                    labelText: AppString.colPhone,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        _requiredValidator(v, phoneRequiredMessage),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimens.spacingMD),
          DesktopFormSection(
            title: 'Parcel',
            child: Row(
              children: [
                Expanded(
                  child: _DialogTextField(
                    controller: parcelCtrl,
                    labelText: AppString.colParcelType,
                    prefixIcon: Icons.local_shipping_outlined,
                  ),
                ),
                const SizedBox(width: Dimens.spacingSM),
                Expanded(
                  child: _DialogTextField(
                    controller: numberCtrl,
                    labelText: AppString.colNumber,
                    prefixIcon: Icons.confirmation_number_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        _requiredValidator(v, 'Number is required'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimens.spacingMD),
          DesktopFormSection(
            title: 'Payment',
            child: Row(
              children: [
                Expanded(
                  child: _DialogTextField(
                    controller: chargesCtrl,
                    labelText: AppString.colCharges,
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    inputFormatters: MoneyInput.inputFormatters,
                    validator: MoneyInput.validateRequiredKyat,
                  ),
                ),
                const SizedBox(width: Dimens.spacingSM),
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                ),
                const SizedBox(width: Dimens.spacingSM),
                Expanded(
                  child: _DialogTextField(
                    controller: cashAdvanceCtrl,
                    labelText: cashAdvanceLabel,
                    prefixIcon: Icons.savings_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: MoneyInput.inputFormatters,
                    validator: MoneyInput.validateOptionalKyat,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => onSubmit(),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
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

Future<void> showViewTransactionDialog(
  BuildContext context,
  DbTransaction t,
) async {
  await showDialog(
    context: context,
    builder: (ctx) {
      void close() => Navigator.of(ctx).pop();
      final customer = (t.customerName?.trim().isNotEmpty ?? false)
          ? t.customerName!.trim()
          : '-';
      final comment = (t.comment?.trim().isNotEmpty ?? false)
          ? t.comment!.trim()
          : '-';

      return DesktopDialogShortcuts(
        onCancel: close,
        onSubmit: close,
        child: fluent.ContentDialog(
          constraints: const BoxConstraints(maxWidth: 760),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  AppString.dialogTransactionDetails,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _TransactionStatusBadge(
                label: t.pickedUp ? 'Claimed' : 'Unclaimed',
                color: t.pickedUp ? AppColor.success : AppColor.warning,
              ),
            ],
          ),
          content: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: 680,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DesktopFormSection(
                    title: 'Transaction',
                    child: _TransactionDetailGrid(
                      children: [
                        _TransactionDetailField(
                          label: 'Customer',
                          value: customer,
                        ),
                        _TransactionDetailField(
                          label: AppString.colPhone,
                          value: t.phone,
                        ),
                        _TransactionDetailField(
                          label: AppString.colParcelType,
                          value: t.parcelType,
                        ),
                        _TransactionDetailField(
                          label: AppString.colNumber,
                          value: t.number,
                        ),
                        _TransactionDetailField(
                          label: AppString.colCharges,
                          value: Format.money(t.charges),
                          alignRight: true,
                        ),
                        _TransactionDetailField(
                          label: AppString.colCashAdvance,
                          value: Format.money(t.cashAdvance),
                          alignRight: true,
                        ),
                        _TransactionDetailField(
                          label: AppString.colPaymentStatus,
                          value: t.paymentStatus,
                        ),
                        _TransactionDetailField(
                          label: AppString.dialogPickedUp,
                          value: t.pickedUp ? 'Yes' : 'No',
                        ),
                        _TransactionDetailField(
                          label: 'Collect Time',
                          value: t.pickedUp
                              ? Format.dateTime12(t.updatedAt)
                              : '-',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimens.spacingMD),
                  DesktopFormSection(
                    title: AppString.dialogComment,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 72),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.spacingSM,
                        vertical: Dimens.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(Dimens.radiusXS),
                        border: Border.all(color: AppColor.border),
                      ),
                      child: Text(
                        comment,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: Dimens.fontSizeBody,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            fluent.FilledButton(
              onPressed: close,
              child: const Text(AppString.dialogClose),
            ),
          ],
        ),
      );
    },
  );
}

class _TransactionDetailGrid extends StatelessWidget {
  const _TransactionDetailGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 560
            ? (constraints.maxWidth - Dimens.spacingMD) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: Dimens.spacingMD,
          runSpacing: Dimens.spacingSM,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _TransactionDetailField extends StatelessWidget {
  const _TransactionDetailField({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingSM,
        vertical: Dimens.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textSecondary,
              fontSize: Dimens.fontSizeCaption,
            ),
          ),
          const SizedBox(height: Dimens.spacingMicro),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: Dimens.fontSizeBody,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionStatusBadge extends StatelessWidget {
  const _TransactionStatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingSM,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: Dimens.fontSizeCaption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> showClaimTransactionDialog(
  BuildContext context,
  InventoryController controller,
  DbTransaction t,
) async {
  final commentCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  try {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSubmitting = false;
        final customer = (t.customerName?.trim().isNotEmpty ?? false)
            ? t.customerName!.trim()
            : '-';

        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              setState(() => isSubmitting = true);
              try {
                await controller.claimTransaction(
                  tx: t,
                  comment: commentCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              } catch (_) {
                if (ctx.mounted) {
                  setState(() => isSubmitting = false);
                }
                rethrow;
              }
            }

            return PopScope(
              canPop: !isSubmitting,
              child: fluent.ContentDialog(
                constraints: const BoxConstraints(maxWidth: 720),
                title: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        AppString.dialogClaimTransaction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _TransactionStatusBadge(
                      label: 'Unclaimed',
                      color: AppColor.warning,
                    ),
                  ],
                ),
                content: Material(
                  type: MaterialType.transparency,
                  child: SizedBox(
                    width: 640,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DesktopFormSection(
                            title: 'Transaction',
                            child: _TransactionDetailGrid(
                              children: [
                                _TransactionDetailField(
                                  label: 'Customer',
                                  value: customer,
                                ),
                                _TransactionDetailField(
                                  label: AppString.colPhone,
                                  value: t.phone,
                                ),
                                _TransactionDetailField(
                                  label: AppString.colParcelType,
                                  value: t.parcelType,
                                ),
                                _TransactionDetailField(
                                  label: AppString.colNumber,
                                  value: t.number,
                                ),
                                _TransactionDetailField(
                                  label: AppString.colCharges,
                                  value: Format.money(t.charges),
                                  alignRight: true,
                                ),
                                _TransactionDetailField(
                                  label: AppString.colCashAdvance,
                                  value: Format.money(t.cashAdvance),
                                  alignRight: true,
                                ),
                                _TransactionDetailField(
                                  label: AppString.colPaymentStatus,
                                  value: t.paymentStatus,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimens.spacingMD),
                          DesktopFormSection(
                            title: AppString.dialogComment,
                            child: TextFormField(
                              controller: commentCtrl,
                              maxLines: 4,
                              textInputAction: TextInputAction.done,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Comment is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Who claimed it or note...',
                                border: OutlineInputBorder(
                                  borderRadius: Dimens.borderRadiusInput,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: Dimens.borderRadiusInput,
                                  borderSide: const BorderSide(
                                    color: AppColor.border,
                                  ),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  fluent.Button(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(ctx).pop(),
                    child: const Text(AppString.dialogCancel),
                  ),
                  fluent.FilledButton(
                    onPressed: isSubmitting ? null : submit,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSubmitting)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.check_circle_outline, size: 16),
                        const SizedBox(width: Dimens.spacingXXS),
                        const Text(AppString.dialogConfirmClaim),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  } finally {
    commentCtrl.dispose();
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
  try {
    return await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final canDelete = value.trim().toLowerCase() == 'confirm';
          return fluent.ContentDialog(
            constraints: const BoxConstraints(maxWidth: 500),
            title: const Text(AppString.dialogDeleteTransaction),
            content: Material(
              type: MaterialType.transparency,
              child: SizedBox(
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
                      'Transaction: No ${t.number} | Customer: ${t.customerName ?? '-'}',
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
            ),
            actions: [
              fluent.Button(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(AppString.dialogCancel),
              ),
              fluent.FilledButton(
                onPressed: canDelete ? () => Navigator.of(ctx).pop(true) : null,
                child: const Text(AppString.dialogDelete),
              ),
            ],
          );
        },
      );
    },
    );
  } finally {
    controller.dispose();
  }
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
      return;
    }

    try {
      await widget.controller.addTransaction(
        driverId: widget.driverId,
        customerName: _nullableTrimmed(_customerCtrl.text),
        phone: _phoneCtrl.text.trim(),
        parcelType: _parcelCtrl.text.trim(),
        number: _numberCtrl.text.trim(),
        charges: MoneyInput.parseRequiredKyatAsDouble(_chargesCtrl.text),
        paymentStatus: _paymentStatus,
        cashAdvance: MoneyInput.parseOptionalKyatAsDouble(
          _cashAdvanceCtrl.text,
        ),
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
    void cancel() => Navigator.of(context).pop();
    return DesktopFormDialog(
      onCancel: cancel,
      onSubmit: _save,
      title: const Text(AppString.dialogAddTransaction),
      actions: [
        fluent.Button(
          onPressed: cancel,
          child: const Text(AppString.dialogCancel),
        ),
        fluent.FilledButton(
          onPressed: _save,
          child: const Text(AppString.dialogSave),
        ),
      ],
      child: _TransactionFormBody(
        formKey: _formKey,
        customerCtrl: _customerCtrl,
        phoneCtrl: _phoneCtrl,
        parcelCtrl: _parcelCtrl,
        numberCtrl: _numberCtrl,
        chargesCtrl: _chargesCtrl,
        cashAdvanceCtrl: _cashAdvanceCtrl,
        paymentStatus: _paymentStatus,
        cashAdvanceLabel: AppString.dialogCashAdvanceOptional,
        phoneRequiredMessage: AppString.dialogPhoneRequiredMm,
        onSubmit: _save,
        onPaymentStatusChanged: (value) => setState(() {
          _paymentStatus = value ?? _paymentStatus;
        }),
      ),
    );
  }
}
