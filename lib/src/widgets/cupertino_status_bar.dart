import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../scaffold_messenger/service.dart';

/// Status bar for cupertino.
///
/// Contains compose action and can display snackbar notifications on ios.
class CupertinoStatusBar extends StatefulHookConsumerWidget {
  const CupertinoStatusBar({
    super.key,
    this.leftAction,
    this.rightAction,
    this.info,
  });

  static const _statusTextStyle = TextStyle(fontSize: 10);
  final Widget? leftAction;
  final Widget? rightAction;
  final Widget? info;

  @override
  ConsumerState<CupertinoStatusBar> createState() => CupertinoStatusBarState();

  static Widget? createInfo(String? text) => (text == null)
      ? null
      : Text(
          text,
          style: _statusTextStyle,
        );
}

class CupertinoStatusBarState extends ConsumerState<CupertinoStatusBar> {
  Widget? _status;
  Widget? _statusAction;
  late double _statusOpacity;

  @override
  void initState() {
    super.initState();
    ScaffoldMessengerService.instance.statusBarState = this;
  }

  @override
  void dispose() {
    super.dispose();
    ScaffoldMessengerService.instance.popStatusBarState();
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
          height: 44,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
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

  Future<void> showTextStatus(String text, {Function()? undo}) async {
    final notification = Text(
      text,
      style: CupertinoStatusBar._statusTextStyle,
    );
    if (undo != null) {
      _statusAction = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CupertinoButton.filled(
          padding: const EdgeInsets.all(8),
          minSize: 20,
          child: Text(
            ref.text.actionUndo,
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
