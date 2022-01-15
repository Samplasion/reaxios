import 'package:flutter/material.dart';

class AlertBottomSheet extends AlertDialog {
  final void Function() onClosing;
  final AnimationController? animationController;
  final bool enableDrag;

  const AlertBottomSheet({
    required this.onClosing,
    this.animationController,
    this.enableDrag = true,
    Key? key,
    Widget? title,
    EdgeInsets? titlePadding,
    TextStyle? titleTextStyle,
    Widget? content,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    TextStyle? contentTextStyle,
    List<Widget>? actions,
    EdgeInsetsGeometry actionsPadding = EdgeInsets.zero,
    MainAxisAlignment? actionsAlignment,
    VerticalDirection? actionsOverflowDirection,
    double? actionsOverflowButtonSpacing,
    EdgeInsets? buttonPadding,
    Color? backgroundColor,
    double? elevation,
    String? semanticLabel,
    EdgeInsets insetPadding =
        const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    Clip clipBehavior = Clip.none,
    ShapeBorder? shape,
    Alignment? alignment,
    bool scrollable = false,
  }) : super(
          key: key,
          title: title,
          titlePadding: titlePadding,
          titleTextStyle: titleTextStyle,
          content: content,
          contentPadding: contentPadding,
          contentTextStyle: contentTextStyle,
          actions: actions,
          actionsPadding: actionsPadding,
          actionsAlignment: actionsAlignment,
          actionsOverflowDirection: actionsOverflowDirection,
          actionsOverflowButtonSpacing: actionsOverflowButtonSpacing,
          buttonPadding: buttonPadding,
          backgroundColor: backgroundColor,
          elevation: elevation,
          semanticLabel: semanticLabel,
          insetPadding: insetPadding,
          clipBehavior: clipBehavior,
          shape: shape,
          alignment: alignment,
          scrollable: scrollable,
        );

  @override
  Widget build(BuildContext context) {
    final Dialog alertBody = super.build(context) as Dialog;

    return BottomSheet(
      onClosing: onClosing,
      animationController: animationController,
      enableDrag: enableDrag,
      builder: (context) => alertBody.child!,
    );
  }
}
