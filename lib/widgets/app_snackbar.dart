import 'package:flutter/material.dart';

import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/strings.dart';

enum AppSnackbarType { info, success, warning, error }

class AppSnackBars {
  const AppSnackBars._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final style = _styleFor(type);
    final resolvedTitle = title ?? _defaultTitleFor(type);
    final textTheme = Theme.of(context).textTheme;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(style.icon, color: AppColor.white, size: 20),
        const SizedBox(width: Dimens.spacingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (resolvedTitle != null)
                Text(
                  resolvedTitle,
                  style: textTheme.titleSmall?.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        color: AppColor.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(color: AppColor.white) ??
                    const TextStyle(color: AppColor.white),
              ),
            ],
          ),
        ),
      ],
    );
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: style.backgroundColor,
      duration: duration,
      content: content,
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static _AppSnackbarStyle _styleFor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return const _AppSnackbarStyle(
          backgroundColor: AppColor.primaryDark,
          icon: Icons.check_circle_outline,
        );
      case AppSnackbarType.warning:
        return const _AppSnackbarStyle(
          backgroundColor: AppColor.warning,
          icon: Icons.warning_amber_rounded,
        );
      case AppSnackbarType.error:
        return const _AppSnackbarStyle(
          backgroundColor: AppColor.error,
          icon: Icons.error_outline,
        );
      case AppSnackbarType.info:
        return const _AppSnackbarStyle(
          backgroundColor: AppColor.info,
          icon: Icons.info_outline,
        );
    }
  }

  static String? _defaultTitleFor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return AppString.snackbarTitleSuccess;
      case AppSnackbarType.warning:
        return AppString.snackbarTitleWarning;
      case AppSnackbarType.error:
        return AppString.snackbarTitleError;
      case AppSnackbarType.info:
        return AppString.snackbarTitleInfo;
    }
  }
}

class _AppSnackbarStyle {
  const _AppSnackbarStyle({
    required this.backgroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final IconData icon;
}
