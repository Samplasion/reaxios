import 'package:flutter/foundation.dart' as foundation;

Future<R> compute<Q, R>(foundation.ComputeCallback<Q, R> callback, Q message,
    {String? debugLabel}) {
  if (foundation.kIsWeb) {
    return Future.microtask(() => callback(message));
  }

  return foundation.compute(callback, message, debugLabel: debugLabel);
}
