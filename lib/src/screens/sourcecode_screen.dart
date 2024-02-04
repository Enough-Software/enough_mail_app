import 'package:enough_mail/mime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'base.dart';

class SourceCodeScreen extends StatelessWidget {
  const SourceCodeScreen({super.key, required this.mimeMessage});
  final MimeMessage mimeMessage;

  @override
  Widget build(BuildContext context) {
    String? sizeText;
    if (mimeMessage.size != null) {
      final sizeFormat = NumberFormat('###.0#');

      final sizeKb = (mimeMessage.size ?? 0) / 1024;
      final sizeMb = sizeKb / 1024;
      sizeText = sizeMb > 1
          ? 'Size: ${sizeFormat.format(sizeKb)} kb  /   ${sizeFormat.format(sizeMb)} mb'
          : 'Size: ${sizeFormat.format(sizeKb)} kb  /   ${mimeMessage.size} bytes';
    }

    return BasePage(
      title: mimeMessage.decodeSubject() ?? '<no subject>',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText('ID: ${mimeMessage.sequenceId}'),
            SelectableText('UID: ${mimeMessage.uid}'),
            if (sizeText != null) SelectableText(sizeText),
            if (mimeMessage.body != null)
              SelectableText('BODY: ${mimeMessage.body}'),
            Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1,
              height: 16,
            ),
            SelectableText(mimeMessage.renderMessage()),
          ],
        ),
      ),
    );
  }
}
