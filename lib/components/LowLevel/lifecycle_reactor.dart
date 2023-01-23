import 'package:flutter/material.dart';

class LifecycleReactor extends StatefulWidget {
  final Widget child;
  final void Function(AppLifecycleState state)? onChange;

  const LifecycleReactor({super.key, required this.child, this.onChange});

  @override
  State<LifecycleReactor> createState() => _LifecycleReactorState();

  AppLifecycleState stateOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_LifecycleReactorState>();
    return state?.state ?? AppLifecycleState.resumed;
  }
}

class _LifecycleReactorState extends State<LifecycleReactor>
    with WidgetsBindingObserver {
  AppLifecycleState state = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.onChange != null) widget.onChange!(state);
    setState(() {
      state = state;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
