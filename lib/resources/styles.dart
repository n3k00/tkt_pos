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

