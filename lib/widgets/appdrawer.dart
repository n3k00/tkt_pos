import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/resources/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute;
    return Drawer(
      child: ListTileTheme(
        // Selected item ရဲ့ icon နဲ့ text color
        selectedColor:
            AppColor.primaryDark, // Or AppColor.textPrimary or AppColor.primary
        // Selected item ရဲ့ background color
        selectedTileColor: AppColor.primaryLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColor.primary),
              margin: EdgeInsets.zero,
              child: Text(
                'TKT POS Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: currentRoute == '/home', // Directly use the route name
              onTap: () {
                Get.back(); // GetX နဲ့ Drawer ပိတ်တာက ပိုကောင်းနိုင်ပါတယ်
                if (currentRoute != '/home') {
                  // လက်ရှိ page က home မဟုတ်မှ navigate လုပ်ပါ
                  Get.offAllNamed('/home');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Inventory'),
              selected: currentRoute == '/inventory',
              onTap: () {
                Get.back();
                if (currentRoute != '/inventory') {
                  Get.offAllNamed('/inventory');
                }
              },
            ),
            // Divider between main and settings
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Get.snackbar('Settings', 'Navigating to Settings');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
