import 'package:flutter/material.dart';

class ScaffoldMessengerService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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

  void showSnackBar(SnackBar snackBar) {
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }

  void showTextSnackBar(String text, {Function() undo}) {
    showSnackBar(buildTextSnackBar(text, undo: undo));
  }
}
