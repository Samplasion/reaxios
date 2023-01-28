import 'package:flutter/material.dart';

/// Builder widget for widgets that need to be animated from 0 (unselected) to
/// 1.0 (selected).
///
/// This widget creates and manages an [AnimationController] that it passes down
/// to the child through the [builder] function.
///
/// When [isSelected] is `true`, the animation controller will animate from
/// 0 to 1 (for [duration] time).
///
/// When [isSelected] is `false`, the animation controller will animate from
/// 1 to 0 (for [duration] time).
///
/// If [isSelected] is updated while the widget is animating, the animation will
/// be reversed until it is either 0 or 1 again.
///
/// Usage:
/// ```dart
/// _SelectableAnimatedBuilder(
///   isSelected: _isDrawerOpen,
///   builder: (context, animation) {
///     return AnimatedIcon(
///       icon: AnimatedIcons.menu_arrow,
///       progress: animation,
///       semanticLabel: 'Show menu',
///     );
///   }
/// )
/// ```
class SelectableAnimatedBuilder extends StatefulWidget {
  /// Builds and maintains an [AnimationController] that will animate from 0 to
  /// 1 and back depending on when [isSelected] is true.
  const SelectableAnimatedBuilder({
    required this.isSelected,
    this.duration = const Duration(milliseconds: 200),
    required this.builder,
  });

  /// When true, the widget will animate an animation controller from 0 to 1.
  ///
  /// The animation controller is passed to the child widget through [builder].
  final bool isSelected;

  /// How long the animation controller should animate for when [isSelected] is
  /// updated.
  ///
  /// If the animation is currently running and [isSelected] is updated, only
  /// the [duration] left to finish the animation will be run.
  final Duration duration;

  /// Builds the child widget based on the current animation status.
  ///
  /// When [isSelected] is updated to true, this builder will be called and the
  /// animation will animate up to 1. When [isSelected] is updated to
  /// `false`, this will be called and the animation will animate down to 0.
  final Widget Function(BuildContext, Animation<double>) builder;

  ///
  @override
  _SelectableAnimatedBuilderState createState() =>
      _SelectableAnimatedBuilderState();
}

/// State that manages the [AnimationController] that is passed to
/// [SelectableAnimatedBuilder.builder].
class _SelectableAnimatedBuilderState extends State<SelectableAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.duration = widget.duration;
    _controller.value = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(SelectableAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _controller,
    );
  }
}
