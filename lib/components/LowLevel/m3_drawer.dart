import 'package:flutter/material.dart';

class M3DrawerHeading extends StatelessWidget {
  final String data;

  const M3DrawerHeading(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Text(
        data,
        style: theme.textTheme.titleSmall!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: ShapeDecoration(
            shape: StadiumBorder(),
            color: selected ? scheme.secondaryContainer : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              customBorder: StadiumBorder(),
              onTap: onTap,
              hoverColor: selected
                  ? ElevationOverlay.applySurfaceTint(
                      scheme.secondaryContainer,
                      scheme.onSecondaryContainer,
                      3, // level 3 is 8% opacity, as required by the spec
                    )
                  : null,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: ListTileTheme(
                    selectedColor: scheme.onSecondaryContainer,
                    child: ListTile(
                      mouseCursor: SystemMouseCursors.click,
                      leading: leading,
                      title: DefaultTextStyle.merge(
                        child: title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: selected,
                      style: ListTileStyle.drawer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
