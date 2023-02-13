import 'package:enough_mail_app/models/web_view_configuration.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart' as webview;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// import '../l10n/app_localizations.g.dart';

class WebViewScreen extends StatelessWidget {
  const WebViewScreen({Key? key, required this.configuration})
      : super(key: key);

  final WebViewConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);

    return Base.buildAppChrome(
      context,
      title: configuration.title ?? configuration.uri.host,
      content: SafeArea(
        child: webview.InAppWebView(
          initialUrlRequest: webview.URLRequest(
            url: webview.WebUri.uri(configuration.uri),
          ),
        ),
      ),
    );
  }
}
