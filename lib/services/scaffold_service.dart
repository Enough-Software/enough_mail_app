import 'package:flutter/material.dart';

class ScaffoldService {
  // waiting for flutter 1.23 to become stable:
  //final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // compare: https://flutter.dev/docs/release/breaking-changes/scaffold-messenger

  SnackBar buildTextSnackBar(String text, {Function() undo}) {
    return SnackBar(
      content: Text(text),
      action: undo == null
          ? null
          : SnackBarAction(
              label: 'Undo',
              onPressed: undo,
            ),
    );
  }

  void showSnackBar(BuildContext context, SnackBar snackBar) {
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void showTextSnackBar(BuildContext context, String text, {Function() undo}) {
    showSnackBar(context, buildTextSnackBar(text, undo: undo));
  }
}
