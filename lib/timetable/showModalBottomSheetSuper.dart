// Source: https://github.com/marcglasberg/assorted_layout_widgets/blob/master/lib/src/show_dialog_super.dart

import 'package:flutter/material.dart';
import 'package:just_bottom_sheet/drag_zone_position.dart';
import 'package:just_bottom_sheet/just_bottom_sheet.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_configuration.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_drag_zone.dart';

/// Displays a Material dialog above the current contents of the app, with
/// Material entrance and exit animations, modal barrier color, and modal
/// barrier behavior (dialog is dismissible with a tap on the barrier).
///
/// This function takes a [builder] which typically builds a [BottomSheet] widget.
/// Content below the dialog is dimmed with a [ModalBarrier]. The widget
/// returned by the [builder] does not share a context with the location that
/// [showModalBottomSheetSuper] is originally called from. Use a [StatefulBuilder] or a
/// custom [StatefulWidget] if the dialog needs to update dynamically.
///
/// The [child] argument is deprecated, and should be replaced with [builder].
///
/// The [context] argument is used to look up the [Navigator] and [Theme] for
/// the dialog. It is only used when the method is called. Its corresponding
/// widget can be safely removed from the tree before the dialog is closed.
///
/// The [onDismissed] callback will be called when the dialog is dismissed.
/// Note: If the dialog is popped by `Navigator.of(context).pop(result)`,
/// then the `result` will be available to the callback. That way you can
/// differentiate between the dialog being dismissed by an Ok or a Cancel
/// button, for example.
///
/// The [barrierDismissible] argument is used to indicate whether tapping on the
/// barrier will dismiss the dialog. It is `true` by default and can not be `null`.
///
/// The [barrierColor] argument is used to specify the color of the modal
/// barrier that darkens everything below the dialog. If `null` the default color
/// `Colors.black54` is used.
///
/// The [useSafeArea] argument is used to indicate if the dialog should only
/// display in 'safe' areas of the screen not used by the operating system
/// (see [SafeArea] for more details). It is `true` by default, which means
/// the dialog will not overlap operating system areas. If it is set to `false`
/// the dialog will only be constrained by the screen size. It can not be `null`.
///
/// The [useRootNavigator] argument is used to determine whether to push the
/// dialog to the [Navigator] furthest from or nearest to the given [context].
/// By default, [useRootNavigator] is `true` and the dialog route created by
/// this method is pushed to the root navigator. It can not be `null`.
///
/// The [routeSettings] argument is passed to [showGeneralDialog],
/// see [RouteSettings] for details.
///
/// If the application has multiple [Navigator] objects, it may be necessary to
/// call `Navigator.of(context, rootNavigator: true).pop(result)` to close the
/// dialog rather than just `Navigator.pop(context, result)`.
///
/// Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the dialog was closed.
///
/// ### State Restoration in Dialogs
///
/// Using this method will not enable state restoration for the dialog. In order
/// to enable state restoration for a dialog, use [Navigator.restorablePush]
/// or [Navigator.restorablePushNamed] with [DialogRoute].
///
/// For more information about state restoration, see [RestorationManager].
///
/// {@tool sample --template=freeform}
///
/// This sample demonstrates how to create a restorable Material dialog. This is
/// accomplished by enabling state restoration by specifying
/// [MaterialApp.restorationScopeId] and using [Navigator.restorablePush] to
/// push [DialogRoute] when the button is tapped.
///
/// {@macro flutter.widgets.RestorationManager}
///
/// ```dart imports
/// import 'package:flutter/material.dart';
/// ```
///
/// ```dart
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       restorationScopeId: 'app',
///       title: 'Restorable Routes Demo',
///       home: MyHomePage(),
///     );
///   }
/// }
///
/// class MyHomePage extends StatelessWidget {
///   static Route<Object?> _dialogBuilder(BuildContext context, Object? arguments) {
///     return DialogRoute<void>(
///       context: context,
///       builder: (BuildContext context) => const AlertDialog(title: Text('Material Alert!')),
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(
///         child: OutlinedButton(
///           onPressed: () {
///             Navigator.of(context).restorablePush(_dialogBuilder);
///           },
///           child: const Text('Open Dialog'),
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// {@end-tool}
///
/// See also:
///
///  * [AlertDialog], for dialogs that have a row of buttons below a body.
///  * [SimpleDialog], which handles the scrolling of the contents and does
///    not show buttons below its body.
///  * [Dialog], on which [SimpleDialog] and [AlertDialog] are based.
///  * [showCupertinoDialog], which displays an iOS-style dialog.
///  * [showGeneralDialog], which allows for customization of the dialog popup.
///  * <https://material.io/design/components/dialogs.html>
Future<T?> showModalBottomSheetSuper<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required ScrollController scrollController,
  bool closeOnScroll = true,
  double? height,
  void Function(T?)? onDismissed,
}) async {
  T? result = await showJustBottomSheet<T>(
    context: context,
    configuration: JustBottomSheetPageConfiguration(
      scrollController: scrollController,
      builder: (context) => OverflowBox(
        child: builder(context),
      ),
      closeOnScroll: closeOnScroll,
      height: height ?? MediaQuery.of(context).size.height,
    ),
    dragZoneConfiguration: JustBottomSheetDragZoneConfiguration(
      dragZonePosition: DragZonePosition.inside,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 8,
          width: 50,
          color: Colors.grey,
        ),
      ),
    ),
  );

  if (onDismissed != null) onDismissed(result);

  return result;
}
