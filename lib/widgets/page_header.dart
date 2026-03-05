import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/shapes.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.crumbs = const <String>[],
    this.trailing,
    this.onBack,
    this.showBack = true,
    this.showBreadcrumbs = false,
  });

  final String title;
  final List<String> crumbs;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showBack;
  final bool showBreadcrumbs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimens.spacingMD,
        Dimens.spacingSM,
        Dimens.spacingMD,
        Dimens.spacingSM,
      ),
      child: ClipRRect(
        borderRadius: AppShapes.cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: Dimens.paddingCard,
            decoration: BoxDecoration(
              borderRadius: AppShapes.cardRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.white.withValues(alpha: 0.25),
                  AppColor.white.withValues(alpha: 0.18),
                ],
              ),
              border: Border.all(color: AppColor.white.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBreadcrumbs) ...[
                        Row(
                          children: [
                            if (showBack) ...[
                              _BackButton(onTap: onBack ?? () => Get.back()),
                              const SizedBox(width: Dimens.spacingXS),
                            ],
                            Flexible(
                              child: Text(
                                crumbs.isEmpty ? 'Home' : crumbs.join('  >  '),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColor.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimens.spacingXSPlus),
                      ],
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeHeadline,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Dimens.spacingMD),
                  Flexible(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: trailing!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radiusSM),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColor.primaryLight,
          borderRadius: BorderRadius.circular(Dimens.radiusSM),
          border: Border.all(color: AppColor.border),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: AppColor.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

class HeaderSearchField extends StatefulWidget {
  const HeaderSearchField({
    super.key,
    this.hint = 'Enter your search request...',
    this.onChanged,
    this.borderRadius,
  });
  final String hint;
  final ValueChanged<String>? onChanged;
  final BorderRadius? borderRadius;

  @override
  State<HeaderSearchField> createState() => _HeaderSearchFieldState();
}

class _HeaderSearchFieldState extends State<HeaderSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    final radius = widget.borderRadius ??
        BorderRadius.circular(Dimens.radiusJumbo);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColor.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontSize: Dimens.fontSizeBodyLarge,
          height: 1.4,
          color: AppColor.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColor.textSecondary),
          contentPadding: Dimens.inputPadding,
          filled: true,
          fillColor: AppColor.surfaceBackground,
          border: AppShapes.inputBorder(color: AppColor.border).copyWith(
            borderRadius: radius,
          ),
          enabledBorder: AppShapes.inputBorder(color: AppColor.border)
              .copyWith(borderRadius: radius),
          focusedBorder: AppShapes.inputBorder(
            color: AppColor.primaryDark,
            width: 1.2,
          ).copyWith(borderRadius: radius),
          suffixIcon: hasText
              ? Padding(
                  padding:
                      const EdgeInsets.only(right: Dimens.spacingMicro),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Dimens.radiusMDPlus),
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.border),
                        color: AppColor.white,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.only(right: Dimens.spacingMicro),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.border),
                      color: AppColor.white,
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 16,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
  }
}
