import 'package:flutter/material.dart';

/// A State object that can be rebuilt at will.
///
/// This State can be instructed to rebuild immediately (requires
/// the unique key to be added to the tree) or to schedule
/// a rebuild (rebuilds the entire subtree).
abstract class ReloadableState<T extends StatefulWidget> extends State<T> {
  UniqueKey _key = UniqueKey();

  /// Forces a rebuild of the tree.
  ///
  /// Triggers a forced rebuild of the tree by
  /// changing the unique key associated with it.
  ///
  /// ```dart
  /// ElevatedButton(
  ///   child: Text("Rebuild view"),
  ///   onTap: () => rebuild(),
  /// );
  /// ```
  void rebuild() => _key = UniqueKey();

  /// The unique key associated with this tree.
  ///
  /// Attaching this key to a tree will allow that
  /// tree to be rebuilt by calling [rebuild].
  ///
  /// ```dart
  /// ElevatedButton(
  ///   child: Text("Rebuild view"),
  ///   onTap: () => rebuild(),
  /// );
  /// ```
  UniqueKey get key => _key;

  void scheduleRebuild() => (context as Element).markNeedsBuild();
}
