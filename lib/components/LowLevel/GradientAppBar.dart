import 'package:flutter/material.dart';
import 'package:reaxios/utils.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final double elevation;
  final List<Color>? colors;
  final Color? foregroundColor;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final double radius;
  final PreferredSizeWidget? bottom;
  final bool clipBottom;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.elevation = 4.0,
    this.colors,
    this.foregroundColor,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.radius = 15,
    this.bottom,
    this.clipBottom = false,
  }) : super(key: key);

  @override
  Size get preferredSize {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: title,
      elevation: elevation,
      actions: actions,
      bottom: bottom,
    ).preferredSize;
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: SizedBox(
        height: preferredSize.height + MediaQuery.of(context).padding.top,
        child: AppBar(
          title: title,
          leading: leading,
          actions: actions,
          elevation: elevation,
          automaticallyImplyLeading: automaticallyImplyLeading,
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          bottom: _buildBottom(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(radius),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(radius),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors ??
                    <Color>[
                      Theme.of(context).colorScheme.primary.darken(0.1),
                      Theme.of(context).colorScheme.primary.lighten(0.06),
                    ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildBottom(BuildContext context) {
    if (bottom == null) {
      return null;
    }
    if (clipBottom) {
      final ps = bottom!.preferredSize;
      return PreferredSize(
        preferredSize: ps,
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          child: bottom,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(radius),
          ),
        ),
      );
    }
    return bottom!;
  }
}
