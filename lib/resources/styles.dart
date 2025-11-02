import 'package:flutter/material.dart';
import 'package:tkt_pos/resources/colors.dart';

class AppTextStyles {
  // Section/page title
  static TextStyle sectionTitle(BuildContext context) =>
      (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 22))
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
  static MaterialStateProperty<Color?> zebra(int rowIndex,
          {Color even = const Color(0xFFF9FAFB), Color odd = Colors.white}) =>
      MaterialStatePropertyAll(rowIndex.isEven ? even : odd);
}
