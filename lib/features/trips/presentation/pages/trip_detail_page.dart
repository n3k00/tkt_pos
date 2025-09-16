import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/utils/format.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TripMainRow trip = Get.arguments as TripMainRow;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver: ' + trip.driverName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Date: ' + Format.date(trip.date)),
            const SizedBox(height: 8),
            Text('Car: ' + trip.carId),
            const Divider(height: 24),
            Text('Commission: ' + Format.money(trip.commission ?? 0)),
            Text('Labor: ' + Format.money(trip.laborCost ?? 0)),
            Text('Support: ' + Format.money(trip.supportPayment ?? 0)),
            Text('Room: ' + Format.money(trip.roomFee ?? 0)),
          ],
        ),
      ),
    );
  }
}

