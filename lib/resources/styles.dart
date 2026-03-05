import 'package:flutter/material.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';

class AppTextStyles {
  // Section/page title
  static TextStyle sectionTitle(BuildContext context) =>
      (Theme.of(context).textTheme.titleLarge ??
              const TextStyle(fontSize: Dimens.fontSizeStat))
          .copyWith(
    fontWeight: FontWeight.w700,
    color: AppColor.textDefault,
  );

  // Table header
  static const TextStyle tableHeader = TextStyle(
    color: AppColor.textDefault,
    fontWeight: FontWeight.w600,
  );

  // Table cell
  static const TextStyle tableCell = TextStyle(
    color: AppColor.textDefault,
  );
}

class AppTableStyles {
  // Consistent zebra coloring for DataRow backgrounds across the app
  static WidgetStateProperty<Color?> zebra(
          int rowIndex, {
          Color even = AppColor.surfaceBackground,
          Color odd = AppColor.white,
        }) =>
      WidgetStatePropertyAll(rowIndex.isEven ? even : odd);
}
