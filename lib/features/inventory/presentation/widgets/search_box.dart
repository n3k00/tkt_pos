import 'package:flutter/material.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.controller});
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

