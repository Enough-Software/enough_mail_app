import 'package:flutter/material.dart';

class AlertService {
  Future<bool> askForConfirmation(BuildContext context,
      {@required String title,
      @required String query,
      String action,
      bool isDangerousAction}) {
    final theme = Theme.of(context);
    var actionButtonStyle = theme.textButtonTheme.style;
    var actionTextStyle = theme.textTheme.button;
    if (isDangerousAction == true) {
      actionButtonStyle = TextButton.styleFrom(
          backgroundColor: Colors.red, onSurface: Colors.white);
      actionTextStyle = actionTextStyle.copyWith(color: Colors.white);
    }

    return showDialog<bool>(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(query),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(action ?? title, style: actionTextStyle),
            onPressed: () => Navigator.of(context).pop(true),
            style: actionButtonStyle,
          ),
        ],
      ),
      context: context,
    );
  }
}
