import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

/// Status bar for cupertino.
///
/// Contains compose action and can display snackbar notifications on ios.
class StatusBar extends StatefulWidget {
  final Widget leftAction;
  final Widget rightAction;
  StatusBar({this.leftAction, this.rightAction})
      : super(key: locator<ScaffoldMessengerService>().statusBarKey);

  @override
  StatusBarState createState() => StatusBarState();
}

class StatusBarState extends State<StatusBar> {
  Widget _status;
  Widget _statusAction;
  double _statusOpacity;
  void showTextStatus(String text, {Function() undo}) async {
    final notification = Text(
      text,
      textAlign: TextAlign.center,
    );
    if (undo != null) {
      _statusAction = CupertinoButton(
        child: Text(
          locator<I18nService>().localizations.actionUndo,
        ),
        onPressed: undo,
      );
    } else if (_statusAction != null) {
      _statusAction = null;
    }
    setState(() {
      _statusOpacity = 1.0;
      _status = notification;
    });
    await Future.delayed(const Duration(seconds: 4));
    if (_status == notification && mounted) {
      setState(() {
        _statusOpacity = 0.0;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (_status == notification && mounted) {
        setState(() {
          _status = null;
          _statusAction = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lAction = widget.leftAction;
    final sAction = (_statusAction == null)
        ? null
        : AnimatedOpacity(
            opacity: _statusOpacity,
            duration: const Duration(milliseconds: 400),
            child: _statusAction);
    final rAction = (sAction != null && widget.rightAction != null)
        ? Stack(
            alignment: Alignment.bottomRight,
            children: [
              AnimatedOpacity(
                  opacity: 1.0 - _statusOpacity,
                  duration: const Duration(milliseconds: 400),
                  child: widget.rightAction),
              sAction
            ],
          )
        : (sAction != null)
            ? sAction
            : widget.rightAction;
    final middle = (_status != null)
        ? Expanded(
            child: AnimatedOpacity(
              opacity: _statusOpacity,
              duration: const Duration(milliseconds: 400),
              child: _status,
            ),
          )
        : Spacer();
    return CupertinoBar(
      blurBackground: true,
      backgroundOpacity: 0.8,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (lAction != null) ...{
              lAction,
            },
            middle,
            if (rAction != null) ...{
              rAction,
            },
          ],
        ),
      ),
    );
  }
}
