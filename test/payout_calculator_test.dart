import 'package:flutter_test/flutter_test.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/payout_calculator.dart';

void main() {
  test(
    'payout calculator uses pending charges plus cash advance minus fees',
    () {
      final driver = _driver(roomFee: 100, laborFee: 200, deliveryFee: 50);
      final transactions = [
        _transaction(
          id: 1,
          charges: 1000,
          cashAdvance: 40,
          paymentStatus: AppString.paymentPending,
        ),
        _transaction(
          id: 2,
          charges: 500,
          cashAdvance: 10,
          paymentStatus: AppString.paymentPaid,
        ),
      ];

      final breakdown = PayoutCalculator.forDriver(driver, transactions);

      expect(breakdown.totalCharges, 1500);
      expect(breakdown.paymentPaid, 500);
      expect(breakdown.paymentPending, 1000);
      expect(breakdown.cashAdvance, 50);
      expect(breakdown.totalFees, 350);
      expect(breakdown.currentPayable, 700);
      expect(breakdown.pendingPayoutAmount, 700);
    },
  );

  test(
    'payout calculator preserves paid out snapshot and reports difference',
    () {
      final driver = _driver(roomFee: 100, paidOut: true, paidOutAmount: 900);
      final transactions = [
        _transaction(
          id: 1,
          charges: 1000,
          paymentStatus: AppString.paymentPending,
        ),
        _transaction(
          id: 2,
          charges: 200,
          paymentStatus: AppString.paymentPending,
        ),
      ];

      final breakdown = PayoutCalculator.forDriver(driver, transactions);

      expect(breakdown.currentPayable, 1100);
      expect(breakdown.displayedPaidOutAmount, 900);
      expect(breakdown.pendingPayoutAmount, 0);
      expect(breakdown.difference, 200);
    },
  );

  test('report payout summary follows shared pending payout formula', () {
    final driver = _driver(roomFee: 100);
    final transactions = [
      _transaction(
        id: 1,
        charges: 1000,
        cashAdvance: 50,
        paymentStatus: AppString.paymentPending,
      ),
      _transaction(id: 2, charges: 700, paymentStatus: AppString.paymentPaid),
    ];

    final summary = PayoutDriverSummary.from(driver, transactions);

    expect(summary.totalCharges, 1700);
    expect(summary.paymentPaid, 700);
    expect(summary.paymentPending, 1000);
    expect(summary.cashAdvance, 50);
    expect(summary.totalFees, 100);
    expect(summary.currentPayable, 950);
    expect(summary.pendingAmount, 950);
  });
}

Driver _driver({
  double? roomFee,
  double? laborFee,
  double? deliveryFee,
  bool paidOut = false,
  double? paidOutAmount,
}) {
  return Driver(
    id: 1,
    date: DateTime(2026, 1, 1),
    name: 'Driver',
    roomFee: roomFee,
    laborFee: laborFee,
    deliveryFee: deliveryFee,
    paidOut: paidOut,
    paidOutAmount: paidOutAmount,
  );
}

DbTransaction _transaction({
  required int id,
  required double charges,
  double cashAdvance = 0,
  required String paymentStatus,
}) {
  return DbTransaction(
    id: id,
    customerName: 'Customer',
    phone: '09123456789',
    parcelType: 'Box',
    number: '1',
    charges: charges,
    paymentStatus: paymentStatus,
    cashAdvance: cashAdvance,
    pickedUp: false,
    driverId: 1,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}
