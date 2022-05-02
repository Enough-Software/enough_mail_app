import 'package:enough_mail_app/models/web_view_configuration.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import '../l10n/app_localizations.g.dart';

class WebViewScreen extends StatelessWidget {
  final WebViewConfiguration configuration;

  const WebViewScreen({Key? key, required this.configuration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);

    return Base.buildAppChrome(
      context,
      title: configuration.title ?? configuration.uri.host,
      content: SafeArea(
        child: WebView(
          initialUrl: configuration.uri.toString(),
        ),
      ),
    );
  }
}
