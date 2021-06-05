import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

/// Status bar for cupertino.
///
/// Contains compose action and can display snackbar notifications on ios.
class CupertinoStatusBar extends StatefulWidget {
  final Widget leftAction;
  final Widget rightAction;
  CupertinoStatusBar({this.leftAction, this.rightAction})
      : super(key: locator<ScaffoldMessengerService>().statusBarKey);

  @override
  CupertinoStatusBarState createState() => CupertinoStatusBarState();
}

class CupertinoStatusBarState extends State<CupertinoStatusBar> {
  static const _statusTextStyle = const TextStyle(fontSize: 10.0);
  Widget _status;
  Widget _statusAction;
  double _statusOpacity;
  Widget _permanentStatus;

  @override
  Widget build(BuildContext context) {
    final lAction = widget.leftAction;
    final sAction = (_statusAction == null)
        ? null
        : AnimatedOpacity(
            opacity: _statusOpacity,
            duration: const Duration(milliseconds: 400),
            child: _statusAction,
          );
    final rAction = (sAction != null && widget.rightAction != null)
        ? AnimatedOpacity(
            opacity: 1.0 - _statusOpacity,
            duration: const Duration(milliseconds: 400),
            child: widget.rightAction,
          )
        : widget.rightAction;
    final middle = (_status != null)
        ? AnimatedOpacity(
            opacity: _statusOpacity,
            duration: const Duration(milliseconds: 400),
            child: _status,
          )
        : _permanentStatus ?? Spacer();
    return CupertinoBar(
      blurBackground: true,
      backgroundOpacity: 0.8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 44.0,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: middle,
                ),
              ),
              if (lAction != null) ...{
                Align(
                  alignment: Alignment.centerLeft,
                  child: lAction,
                ),
              },
              if (rAction != null) ...{
                Align(
                  alignment: Alignment.centerRight,
                  child: rAction,
                ),
              },
              if (sAction != null) ...{
                Align(
                  alignment: Alignment.centerRight,
                  child: sAction,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  void showPermanentStatus(String text) {
    setState(() {
      _permanentStatus = (text == null)
          ? null
          : Text(
              text,
              style: _statusTextStyle,
            );
    });
  }

  void showTextStatus(String text, {Function() undo}) async {
    final notification = Text(
      text,
      style: _statusTextStyle,
    );
    if (undo != null) {
      _statusAction = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: CupertinoButton.filled(
          padding: EdgeInsets.all(8.0),
          minSize: 20.0,
          child: Text(
            locator<I18nService>().localizations.actionUndo,
            style: _statusTextStyle,
          ),
          onPressed: () {
            setState(() {
              _status = null;
              _statusAction = null;
            });
            undo();
          },
        ),
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
}
