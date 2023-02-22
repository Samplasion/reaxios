import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class UndisposingChangeNotifierProvider<T extends ChangeNotifier?>
    extends ListenableProvider<T> {
  /// Creates a [ChangeNotifier] using `create` and never disposes it.
  ///
  /// `create` must not be `null`.
  UndisposingChangeNotifierProvider({
    Key? key,
    required Create<T> create,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          create: create,
          dispose: _dispose,
          lazy: lazy,
          builder: builder,
          child: child,
        );

  /// Provides an existing [ChangeNotifier].
  UndisposingChangeNotifierProvider.value({
    Key? key,
    required T value,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(
          key: key,
          builder: builder,
          value: value,
          child: child,
        );

  static void _dispose(BuildContext context, ChangeNotifier? notifier) {
    Logger.d("Fake-disposing $notifier");
  }
}
