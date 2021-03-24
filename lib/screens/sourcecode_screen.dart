import 'package:enough_mail/mime_message.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:flutter/material.dart';

class SourceCodeScreen extends StatelessWidget {
  final MimeMessage mimeMessage;
  const SourceCodeScreen({Key key, @required this.mimeMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: mimeMessage.decodeSubject() ?? '<no subject>',
      content: SingleChildScrollView(
        child: SelectableText(mimeMessage.renderMessage()),
      ),
    );
  }
}
