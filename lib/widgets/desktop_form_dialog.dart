import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';

class DesktopFormDialog extends StatelessWidget {
  const DesktopFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    required this.onCancel,
    required this.onSubmit,
    this.maxWidth = 820,
    this.contentWidth = 740,
    this.maxContentHeight = 560,
  });

  final Widget title;
  final Widget child;
  final List<Widget> actions;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final double maxWidth;
  final double contentWidth;
  final double maxContentHeight;

  @override
  Widget build(BuildContext context) {
    return DesktopDialogShortcuts(
      onCancel: onCancel,
      onSubmit: onSubmit,
      child: fluent.ContentDialog(
        constraints: BoxConstraints(maxWidth: maxWidth),
        title: title,
        content: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: contentWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxContentHeight),
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
        actions: actions,
      ),
    );
  }
}

class DesktopFormSection extends StatelessWidget {
  const DesktopFormSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.spacingMD),
      decoration: BoxDecoration(
        color: AppColor.surfaceBackground,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Dimens.spacingSM),
          child,
        ],
      ),
    );
  }
}

class DesktopDialogShortcuts extends StatelessWidget {
  const DesktopDialogShortcuts({
    super.key,
    required this.child,
    required this.onCancel,
    required this.onSubmit,
  });

  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _CancelDialogIntent(),
        SingleActivator(LogicalKeyboardKey.enter): _SubmitDialogIntent(),
      },
      child: Actions(
        actions: {
          _CancelDialogIntent: CallbackAction<_CancelDialogIntent>(
            onInvoke: (_) {
              onCancel();
              return null;
            },
          ),
          _SubmitDialogIntent: CallbackAction<_SubmitDialogIntent>(
            onInvoke: (_) {
              onSubmit();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class _CancelDialogIntent extends Intent {
  const _CancelDialogIntent();
}

class _SubmitDialogIntent extends Intent {
  const _SubmitDialogIntent();
}
