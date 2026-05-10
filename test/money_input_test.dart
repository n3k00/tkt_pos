import 'package:flutter_test/flutter_test.dart';
import 'package:tkt_pos/utils/money_input.dart';

void main() {
  test('required kyat rejects empty, decimal, and negative amounts', () {
    expect(MoneyInput.validateRequiredKyat(''), 'Amount is required');
    expect(MoneyInput.validateRequiredKyat('10.5'), 'Enter whole kyat only');
    expect(MoneyInput.validateRequiredKyat('-1000'), 'Enter whole kyat only');
  });

  test('whole kyat parser accepts comma formatted values', () {
    expect(MoneyInput.validateRequiredKyat('10,000'), isNull);
    expect(MoneyInput.parseRequiredKyatAsDouble('10,000'), 10000);
  });

  test('optional kyat treats empty as zero but rejects invalid values', () {
    expect(MoneyInput.validateOptionalKyat(''), isNull);
    expect(MoneyInput.parseOptionalKyatAsDouble(''), 0);
    expect(MoneyInput.validateOptionalKyat('1.25'), 'Enter whole kyat only');
    expect(MoneyInput.validateOptionalKyat('-1'), 'Enter whole kyat only');
  });
}
