import 'package:flutter/widgets.dart';

class Dimens {
  // Base spacing units
  static const double d4 = 4;
  static const double d8 = 8;
  static const double d12 = 12;
  static const double d14 = 14;
  static const double d16 = 16;
  static const double d24 = 24;

  // Common paddings
  static const EdgeInsets screen = EdgeInsets.all(d16);

  // Common input paddings
  static const EdgeInsets inputPadding16 =
      EdgeInsets.symmetric(horizontal: d12, vertical: d16);
  static const EdgeInsets inputPadding14 =
      EdgeInsets.symmetric(horizontal: d12, vertical: d14);
}

