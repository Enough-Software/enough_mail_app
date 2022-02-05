import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';

import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';

import '../locator.dart';

/// Status bar for cupertino.
///
/// Contains compose action and can display snackbar notifications on ios.
class CupertinoStatusBar extends StatefulWidget {
  const CupertinoStatusBar({
    Key? key,
    this.leftAction,
    this.rightAction,
    this.info,
  }) : super(key: key);

  static const _statusTextStyle = TextStyle(fontSize: 10.0);
  final Widget? leftAction;
  final Widget? rightAction;
  final Widget? info;

  @override
  CupertinoStatusBarState createState() => CupertinoStatusBarState();

  static Widget? createInfo(String? text) {
    return (text == null)
        ? null
        : Text(
            text,
            style: _statusTextStyle,
          );
  }
}

class CupertinoStatusBarState extends State<CupertinoStatusBar> {
  Widget? _status;
  Widget? _statusAction;
  late double _statusOpacity;

  @override
  void initState() {
    super.initState();
    locator<ScaffoldMessengerService>().statusBarState = this;
  }

  @override
  void dispose() {
    super.dispose();
    locator<ScaffoldMessengerService>().popStatusBarState();
  }

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
        : widget.info ?? Container();
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
              if (lAction != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: lAction,
                ),
              if (rAction != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: rAction,
                ),
              if (sAction != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: sAction,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void showTextStatus(String text, {Function()? undo}) async {
    final notification = Text(
      text,
      style: CupertinoStatusBar._statusTextStyle,
    );
    if (undo != null) {
      _statusAction = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: CupertinoButton.filled(
          padding: const EdgeInsets.all(8.0),
          minSize: 20.0,
          child: Text(
            locator<I18nService>().localizations.actionUndo,
            style: CupertinoStatusBar._statusTextStyle,
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
