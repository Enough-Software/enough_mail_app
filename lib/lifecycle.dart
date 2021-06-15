import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:flutter/material.dart';

class LifecyleManager extends StatefulWidget {
  final Widget child;
  LifecyleManager({Key? key, required this.child}) : super(key: key);

  @override
  _LifecyleManagerState createState() => _LifecyleManagerState();
}

class _LifecyleManagerState extends State<LifecyleManager>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppEventBus.eventBus.fire(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
