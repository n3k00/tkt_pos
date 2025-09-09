import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/widgets/page_header.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        drawerEnableOpenDragGesture: true,
        drawerEdgeDragWidth: 80,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Reports',
                  crumbs: ['Home', 'Reports'],
                  showBack: false,
                  // Breadcrumbs are hidden by default; enable if needed
                  trailing: HeaderSearchField(hint: 'Search reports...'),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TabBar(
                    onTap: controller.setTab,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.textSecondary,
                    indicatorColor: AppColor.primary,
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Monthly'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _DailyReportsView(),
                      _MonthlyReportsView(),
                    ],
                  ),
                ),
              ],
            ),
            EdgeDrawerOpener(),
          ],
        ),
      ),
    );
  }
}

class _DailyReportsView extends StatelessWidget {
  const _DailyReportsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Report', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Summary and tables for the selected day will appear here.',
          ),
        ],
      ),
    );
  }
}

class _MonthlyReportsView extends StatelessWidget {
  const _MonthlyReportsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Report', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Aggregated monthly metrics and breakdowns will appear here.',
          ),
        ],
      ),
    );
  }
}
