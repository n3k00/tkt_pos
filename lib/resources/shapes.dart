import 'package:flutter/material.dart';

import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/colors.dart';

/// Centralizes reusable shape helpers (border radii, outlines, etc.).
class AppShapes {
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(Dimens.radiusMD));
  static const BorderRadius chipRadius =
      BorderRadius.all(Radius.circular(Dimens.radiusXS));
  static const BorderRadius pillRadius =
      BorderRadius.all(Radius.circular(Dimens.radiusPill));
  static const BorderRadius inputRadius = Dimens.borderRadiusInput;

  static OutlineInputBorder inputBorder({
    Color color = AppColor.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: inputRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
