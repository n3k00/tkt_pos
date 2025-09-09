import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/resources/colors.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.crumbs = const <String>[],
    this.trailing,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final List<String> crumbs;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                Row(
                  children: [
                    if (showBack) ...[
                      _BackButton(onTap: onBack ?? () => Get.back()),
                      const SizedBox(width: 8),
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
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              child: trailing,
            ),
          ],
        ],
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColor.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.border),
        ),
        child: const Icon(Icons.arrow_back, color: AppColor.textPrimary, size: 18),
      ),
    );
  }
}

class HeaderSearchField extends StatelessWidget {
  const HeaderSearchField({super.key, this.hint = 'Search...'});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColor.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColor.primaryDark),
        ),
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColor.textSecondary),
      ),
    );
  }
}

