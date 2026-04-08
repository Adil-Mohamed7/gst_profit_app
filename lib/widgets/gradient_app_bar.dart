import 'package:flutter/material.dart';
import 'package:gst_profit_app/constants/app_colors.dart';

/// Reusable AppBar with gradient
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final LinearGradient? backgroundGradient;
  final Color? backgroundColor;
  final bool centerTitle;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundGradient,
    this.backgroundColor,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: centerTitle,
      titleSpacing: 8,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: backgroundColor != null
            ? BoxDecoration(color: backgroundColor)
            : (backgroundGradient != null
                ? BoxDecoration(gradient: backgroundGradient)
                : BoxDecoration(color: AppColors.primary)),
      ),
      backgroundColor: backgroundColor ?? Colors.transparent,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
