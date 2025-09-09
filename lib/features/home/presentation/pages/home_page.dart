import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/home/presentation/controllers/home_controller.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/widgets/page_header.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 80,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PageHeader(
                title: AppString.title,
                crumbs: ['Home'],
                showBack: false,
              ),
              Expanded(
                child: Center(child: Text(AppString.title)),
              ),
            ],
          ),
          EdgeDrawerOpener(),
        ],
      ),
    );
  }
}
