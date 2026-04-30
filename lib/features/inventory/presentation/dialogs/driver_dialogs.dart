import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/strings.dart';

Future<void> showEditDriverDialog(
  BuildContext context,
  InventoryController controller,
  Driver driver,
) async {
  final nameController = TextEditingController(text: driver.name);
  DateTime date = driver.date;
  final formKey = GlobalKey<FormState>();
  try {
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              await controller.updateDriver(
                id: driver.id,
                date: date,
                name: nameController.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            }

            return _DriverDialogShortcuts(
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: save,
              child: fluent.ContentDialog(
                constraints: const BoxConstraints(maxWidth: 680),
                title: const Text(AppString.dialogEditDriver),
                content: _DriverDialogContent(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: _DriverFormFields(
                      nameController: nameController,
                      date: date,
                      onSubmit: save,
                      onPickDate: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                    ),
                  ),
                ),
                actions: [
                  fluent.Button(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(AppString.dialogCancel),
                  ),
                  fluent.FilledButton(
                    onPressed: save,
                    child: const Text(AppString.dialogSave),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  } finally {
    nameController.dispose();
  }
}

Future<void> showAddDriverDialog(
  BuildContext context,
  InventoryController controller,
) async {
  final nameController = TextEditingController();
  DateTime date = DateTime.now();
  final formKey = GlobalKey<FormState>();
  try {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(ctx).pop();
              await controller.addDriver(
                date: date,
                name: nameController.text.trim(),
              );
            }

            return _DriverDialogShortcuts(
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: save,
              child: fluent.ContentDialog(
                constraints: const BoxConstraints(maxWidth: 680),
                title: const Text(AppString.dialogAddDriver),
                content: _DriverDialogContent(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: _DriverFormFields(
                      nameController: nameController,
                      date: date,
                      onSubmit: save,
                      onPickDate: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                    ),
                  ),
                ),
                actions: [
                  fluent.Button(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(AppString.dialogCancel),
                  ),
                  fluent.FilledButton(
                    onPressed: save,
                    child: const Text(AppString.dialogSave),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  } finally {
    nameController.dispose();
  }
}

class _DriverFormFields extends StatelessWidget {
  const _DriverFormFields({
    required this.nameController,
    required this.date,
    required this.onPickDate,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final DateTime date;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.spacingMD),
      decoration: BoxDecoration(
        color: AppColor.surfaceBackground,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                labelText: AppString.dialogDriverNameHint,
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: Dimens.borderRadiusInput,
                ),
                isDense: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppString.dialogDriverNameRequired
                  : null,
            ),
          ),
          const SizedBox(width: Dimens.spacingSM),
          Expanded(
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: Dimens.borderRadiusInput,
                side: const BorderSide(color: AppColor.border),
              ),
              title: const Text(AppString.dialogDateLabel),
              subtitle: Text(_formatDate(date)),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: onPickDate,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
  }
}

class _DriverDialogContent extends StatelessWidget {
  const _DriverDialogContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(width: 600, child: child),
    );
  }
}

class _DriverDialogShortcuts extends StatelessWidget {
  const _DriverDialogShortcuts({
    required this.child,
    required this.onCancel,
    required this.onSubmit,
  });

  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _CancelDriverDialogIntent(),
        SingleActivator(LogicalKeyboardKey.enter): _SubmitDriverDialogIntent(),
      },
      child: Actions(
        actions: {
          _CancelDriverDialogIntent: CallbackAction<_CancelDriverDialogIntent>(
            onInvoke: (_) {
              onCancel();
              return null;
            },
          ),
          _SubmitDriverDialogIntent: CallbackAction<_SubmitDriverDialogIntent>(
            onInvoke: (_) {
              onSubmit();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class _CancelDriverDialogIntent extends Intent {
  const _CancelDriverDialogIntent();
}

class _SubmitDriverDialogIntent extends Intent {
  const _SubmitDriverDialogIntent();
}
