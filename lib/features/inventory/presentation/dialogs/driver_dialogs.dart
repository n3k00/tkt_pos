import 'package:flutter/material.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/colors.dart';

Future<void> showEditDriverDialog(
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
                        hintText: 'Driver name',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: AppColor.surfaceBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: AppColor.primaryDark,
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: AppColor.textSecondary,
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
Future<void> showAddDriverDialog(
  BuildContext context,
  InventoryController controller,
) async {
  final nameController = TextEditingController();
  DateTime date = DateTime.now();
  final formKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    barrierDismissible: false, // require explicit action to close
    builder: (ctx) {
      return WillPopScope(
        onWillPop: () async => false, // block back/Escape dismiss
        child: StatefulBuilder(
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
                      hintText: 'Driver name',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: AppColor.surfaceBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColor.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColor.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: AppColor.primaryDark,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColor.textSecondary,
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
                  // Close dialog before awaiting to avoid using context after await
                  Navigator.of(ctx).pop();
                  await controller.addDriver(date: date, name: name);
                },
                child: const Text('Save'),
              ),
            ],
          );
          },
        ),
      );
    },
  );
}
