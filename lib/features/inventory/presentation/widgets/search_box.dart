import 'package:flutter/material.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/shapes.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.controller});
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: AppString.searchLabel,
        hintText: AppString.searchHint,
        prefixIcon: const Icon(Icons.search),
        contentPadding: Dimens.inputPaddingDense,
        filled: true,
        fillColor: AppColor.surfaceBackground,
        border: AppShapes.inputBorder(),
        enabledBorder: AppShapes.inputBorder(),
        focusedBorder: AppShapes.inputBorder(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
      onChanged: controller.setSearch,
    );
  }
}
