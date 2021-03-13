import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

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

  Future showTextDialog(BuildContext context, String title, String text) {
    return showDialog(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(title),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      context: context,
    );
  }

  Future showWidgetDialog(BuildContext context, String title, Widget content) {
    return showDialog(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      context: context,
    );
  }

  void showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Maily',
      applicationVersion: '1.0.0-Beta',
      applicationIcon: Icon(Icons.email),
      applicationLegalese:
          'Maily is free software published under the GNU General Public License.',
      children: [
        ElevatedButton(
          child: Text('Suggest a feature'),
          onPressed: () async {
            await launcher.launch('https://maily.userecho.com/');
          },
        ),
        ElevatedButton(
          child: Text('Report a problem'),
          onPressed: () async {
            await launcher.launch('https://maily.userecho.com/');
          },
        ),
        ElevatedButton(
          child: Text('Help developing Maily'),
          onPressed: () async {
            await launcher
                .launch('https://github.com/Enough-Software/enough_mail_app');
          },
        ),
      ],
    );
  }
}
