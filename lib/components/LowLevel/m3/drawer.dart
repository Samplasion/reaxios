import 'package:flutter/material.dart';
import 'package:reaxios/components/LowLevel/selectable_animated.dart';

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
  final Widget icon;
  final Widget title;
  final Widget? selectedIcon;
  final bool selected;
  final void Function() onTap;

  const M3DrawerListTile({
    super.key,
    required this.icon,
    required this.title,
    this.selectedIcon,
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
            // color: selected ? scheme.secondaryContainer : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            type: MaterialType.transparency,
            child: SelectableAnimatedBuilder(
                isSelected: selected,
                builder: (context, animation) {
                  return Stack(
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        return NavigationIndicator(
                          animation: animation,
                          color: scheme.secondaryContainer,
                          shape: StadiumBorder(),
                          width: constraints.maxWidth,
                          height: 56,
                        );
                      }),
                      InkWell(
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
                              iconColor: selected
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurfaceVariant,
                              textColor: selected
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurfaceVariant,
                              selectedColor: scheme.onSecondaryContainer,
                              child: ListTile(
                                mouseCursor: SystemMouseCursors.click,
                                leading: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: () {
                                    if (_isForwardOrCompleted(animation)) {
                                      return KeyedSubtree(
                                        child: selectedIcon ?? icon,
                                        key: ValueKey(selected),
                                      );
                                    }
                                    return KeyedSubtree(
                                      child: icon,
                                      key: ValueKey(selected),
                                    );
                                  }(),
                                ),
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
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}

/// Returns `true` if this animation is ticking forward, or has completed,
/// based on [status].
bool _isForwardOrCompleted(Animation<double> animation) {
  return animation.status == AnimationStatus.forward ||
      animation.status == AnimationStatus.completed;
}
