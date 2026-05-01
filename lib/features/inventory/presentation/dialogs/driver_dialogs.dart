import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/desktop_form_dialog.dart';

Future<void> showEditDriverFeesDialog(
  BuildContext context,
  InventoryController controller,
  Driver driver,
) async {
  final roomFeeController = TextEditingController(
    text: (driver.roomFee ?? 0).toStringAsFixed(0),
  );
  final laborFeeController = TextEditingController(
    text: (driver.laborFee ?? 0).toStringAsFixed(0),
  );
  final deliveryFeeController = TextEditingController(
    text: (driver.deliveryFee ?? 0).toStringAsFixed(0),
  );
  final formKey = GlobalKey<FormState>();

  double parseAmount(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  try {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future<void> save() async {
          if (!formKey.currentState!.validate()) return;
          await controller.updateDriverFees(
            driver: driver,
            roomFee: parseAmount(roomFeeController),
            laborFee: parseAmount(laborFeeController),
            deliveryFee: parseAmount(deliveryFeeController),
          );
          if (ctx.mounted) Navigator.of(ctx).pop();
        }

        return DesktopFormDialog(
          onCancel: () => Navigator.of(ctx).pop(),
          onSubmit: save,
          maxWidth: 680,
          contentWidth: 600,
          title: const Text('Edit fees'),
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
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: DesktopFormSection(
              title: 'Driver fees',
              child: Row(
                children: [
                  Expanded(
                    child: _FeeTextField(
                      controller: roomFeeController,
                      labelText: AppString.driverRoomFee,
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingSM),
                  Expanded(
                    child: _FeeTextField(
                      controller: laborFeeController,
                      labelText: AppString.driverLaborFee,
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingSM),
                  Expanded(
                    child: _FeeTextField(
                      controller: deliveryFeeController,
                      labelText: AppString.driverDeliveryFee,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } finally {
    roomFeeController.dispose();
    laborFeeController.dispose();
    deliveryFeeController.dispose();
  }
}

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

            return DesktopFormDialog(
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: save,
              maxWidth: 680,
              contentWidth: 600,
              title: const Text(AppString.dialogEditDriver),
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
  final profiles = await controller.activeDriverProfiles();
  if (!context.mounted) return;
  if (profiles.isEmpty) {
    await showDialog(
      context: context,
      builder: (ctx) => fluent.ContentDialog(
        title: const Text('No active drivers'),
        content: const Text(
          'Create an active driver profile in Settings > Drivers before adding a daily driver entry.',
        ),
        actions: [
          fluent.FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  DriverProfile selectedProfile = profiles.first;
  DateTime date = DateTime.now();
  final formKey = GlobalKey<FormState>();
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
              profileId: selectedProfile.id,
              name: selectedProfile.name,
            );
          }

          return DesktopFormDialog(
            onCancel: () => Navigator.of(ctx).pop(),
            onSubmit: save,
            maxWidth: 680,
            contentWidth: 600,
            title: const Text(AppString.dialogAddDriver),
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
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: _AddDriverProfileFormFields(
                profiles: profiles,
                selectedProfile: selectedProfile,
                date: date,
                onProfileChanged: (profile) {
                  if (profile != null) {
                    setState(() => selectedProfile = profile);
                  }
                },
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
          );
        },
      );
    },
  );
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
    return DesktopFormSection(
      title: 'Driver',
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

class _FeeTextField extends StatelessWidget {
  const _FeeTextField({required this.controller, required this.labelText});

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: Dimens.borderRadiusInput),
        isDense: true,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return null;
        return double.tryParse(text) == null ? 'Invalid amount' : null;
      },
    );
  }
}

class _AddDriverProfileFormFields extends StatelessWidget {
  const _AddDriverProfileFormFields({
    required this.profiles,
    required this.selectedProfile,
    required this.date,
    required this.onProfileChanged,
    required this.onPickDate,
  });

  final List<DriverProfile> profiles;
  final DriverProfile selectedProfile;
  final DateTime date;
  final ValueChanged<DriverProfile?> onProfileChanged;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return DesktopFormSection(
      title: 'Daily driver entry',
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<DriverProfile>(
              initialValue: selectedProfile,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Driver profile',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: Dimens.borderRadiusInput,
                ),
                isDense: true,
              ),
              items: [
                for (final profile in profiles)
                  DropdownMenuItem(value: profile, child: Text(profile.name)),
              ],
              onChanged: onProfileChanged,
              validator: (value) => value == null ? 'Required' : null,
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
              subtitle: Text(_formatDriverDate(date)),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: onPickDate,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDriverDate(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final yyyy = date.year.toString().padLeft(4, '0');
  return '$dd/$mm/$yyyy';
}
