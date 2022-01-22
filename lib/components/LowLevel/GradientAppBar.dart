import 'package:flutter/material.dart';
import 'package:reaxios/utils.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final double elevation;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final double radius;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.elevation = 4.0,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.radius = 15,
  }) : super(key: key);

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: AppBar(
        title: title,
        leading: leading,
        actions: actions,
        elevation: elevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
              colors: <Color>[
                Theme.of(context).colorScheme.primary.darken(0.1),
                Theme.of(context).colorScheme.primary.lighten(0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
