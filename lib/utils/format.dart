class Format {
  static String money(double v) {
    final isNegative = v < 0;
    var s = v.abs().toStringAsFixed(2);
    // Trim trailing zeros and optional dot
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);

    final parts = s.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? '.${parts[1]}' : '';

    String groupThousands(String d) {
      if (d.length <= 3) return d;
      final first = d.length % 3 == 0 ? 3 : d.length % 3;
      final buf = StringBuffer(d.substring(0, first));
      for (int i = first; i < d.length; i += 3) {
        buf
          ..write(',')
          ..write(d.substring(i, i + 3));
      }
      return buf.toString();
    }

    final withCommas = groupThousands(intPart);
    return (isNegative ? '-' : '') + withCommas + fracPart;
  }

  static String date(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
  }

  static String dateTime24(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$mi';
  }

  static String dateTime12(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    final hour24 = d.hour;
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = (hour24 % 12 == 0) ? 12 : hour24 % 12;
    final hh = hour12.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min $ampm';
  }
}

