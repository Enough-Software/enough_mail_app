import 'package:enough_mail/mime.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SourceCodeScreen extends StatelessWidget {
  final MimeMessage? mimeMessage;
  const SourceCodeScreen({Key? key, required this.mimeMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? sizeText;
    if (mimeMessage!.size != null) {
      final sizeFormat = NumberFormat('###.0#');

      final sizeKb = mimeMessage!.size! / 1024;
      final sizeMb = sizeKb / 1024;
      sizeText = sizeMb > 1
          ? 'Size: ${sizeFormat.format(sizeKb)} kb  /   ${sizeFormat.format(sizeMb)} mb'
          : 'Size: ${sizeFormat.format(sizeKb)} kb  /   ${mimeMessage!.size} bytes';
    }
    return Base.buildAppChrome(
      context,
      title: mimeMessage!.decodeSubject() ?? '<no subject>',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText('ID: ${mimeMessage!.sequenceId}'),
            SelectableText('UID: ${mimeMessage!.uid}'),
            if (sizeText != null) 
              SelectableText(sizeText),
            
            if (mimeMessage!.body != null) 
              SelectableText('BODY: ${mimeMessage!.body}'),
            
            Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1,
              height: 16,
            ),
            SelectableText(mimeMessage!.renderMessage()),
          ],
        ),
      ),
    );
  }
}
