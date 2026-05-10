import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/strings.dart';

class PayoutBreakdown {
  const PayoutBreakdown({
    required this.totalCharges,
    required this.paymentPaid,
    required this.paymentPending,
    required this.cashAdvance,
    required this.roomFee,
    required this.laborFee,
    required this.deliveryFee,
    required this.isPaidOut,
    required this.paidOutAmount,
  });

  final double totalCharges;
  final double paymentPaid;
  final double paymentPending;
  final double cashAdvance;
  final double roomFee;
  final double laborFee;
  final double deliveryFee;
  final bool isPaidOut;
  final double? paidOutAmount;

  double get totalFees => roomFee + laborFee + deliveryFee;

  double get currentPayable => paymentPending + cashAdvance - totalFees;

  double get displayedPaidOutAmount =>
      isPaidOut ? (paidOutAmount ?? currentPayable) : currentPayable;

  double get pendingPayoutAmount => isPaidOut ? 0 : currentPayable;

  double get difference =>
      isPaidOut ? currentPayable - (paidOutAmount ?? currentPayable) : 0;
}

class PayoutCalculator {
  const PayoutCalculator._();

  static PayoutBreakdown forDriver(
    Driver driver,
    Iterable<DbTransaction> transactions, {
    double? roomFee,
    double? laborFee,
    double? deliveryFee,
    bool? paidOut,
    double? paidOutAmount,
  }) {
    final totalCharges = transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.charges,
    );
    final paymentPaid = transactions.fold<double>(
      0,
      (sum, transaction) =>
          sum +
          (isPaymentPaid(transaction.paymentStatus) ? transaction.charges : 0),
    );
    final cashAdvance = transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.cashAdvance,
    );

    return PayoutBreakdown(
      totalCharges: totalCharges,
      paymentPaid: paymentPaid,
      paymentPending: totalCharges - paymentPaid,
      cashAdvance: cashAdvance,
      roomFee: roomFee ?? driver.roomFee ?? 0,
      laborFee: laborFee ?? driver.laborFee ?? 0,
      deliveryFee: deliveryFee ?? driver.deliveryFee ?? 0,
      isPaidOut: paidOut ?? driver.paidOut,
      paidOutAmount: paidOutAmount ?? driver.paidOutAmount,
    );
  }

  static bool isPaymentPaid(String status) {
    final value = status.trim();
    return value == AppString.paymentPaid ||
        value == AppString.paymentPaidLegacy ||
        value == AppString.paymentPaidAltMm ||
        value.toLowerCase() == 'paid';
  }

  static bool isPaymentPending(String status) {
    final value = status.trim();
    return value == AppString.paymentPending ||
        value == AppString.paymentPendingLegacy ||
        value.toLowerCase() == 'pending';
  }
}
