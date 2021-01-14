import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:flutter/widgets.dart';

class MediaScreen extends StatelessWidget {
  final MediaViewer mediaViewer;
  const MediaScreen({Key key, this.mediaViewer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: mediaViewer.mimeMessage.decodeSubject(),
      content: mediaViewer,
    );
  }
}
