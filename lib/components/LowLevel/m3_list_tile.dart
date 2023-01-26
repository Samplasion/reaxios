import 'package:flutter/material.dart';

class M3DrawerListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final bool selected;
  final void Function() onTap;

  const M3DrawerListTile({
    super.key,
    required this.leading,
    required this.title,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(),
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  leading: leading,
                  title: title,
                  selected: selected,
                  style: ListTileStyle.drawer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
