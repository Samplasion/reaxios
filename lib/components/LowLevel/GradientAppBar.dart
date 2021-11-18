import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/utils.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  Key? key;
  Widget title;
  double elevation;
  Widget? leading;
  List<Widget>? actions;
  bool automaticallyImplyLeading;

  GradientAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.elevation = 4.0,
    this.actions,
    this.automaticallyImplyLeading = true,
  }) : super();

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Theme.of(context).colorScheme.primary.darken(0.15),
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
