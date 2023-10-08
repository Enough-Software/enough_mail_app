import 'events/app_event_bus.dart';
import 'package:flutter/material.dart';

class LifecycleManager extends StatefulWidget {
  const LifecycleManager({super.key, required this.child});
  final Widget child;

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppEventBus.eventBus.fire(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
