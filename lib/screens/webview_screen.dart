import 'package:enough_mail_flutter/enough_mail_flutter.dart' as webview;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/web_view_configuration.dart';
import 'base.dart';

// import '../l10n/app_localizations.g.dart';

class WebViewScreen extends StatelessWidget {
  const WebViewScreen({super.key, required this.configuration});

  final WebViewConfiguration configuration;

  @override
  Widget build(BuildContext context) => BasePage(
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
