import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:flutter/cupertino.dart';

class _InheritedMessageContainer extends InheritedWidget {
  final MessageWidgetState data;

  // You must pass through a child and your state.
  _InheritedMessageContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedMessageContainer old) => (old.data != data);
}

class MessageWidget extends StatefulWidget {
  // You must pass through a child.
  final Widget child;
  final Message message;

  MessageWidget({
    Key? key,
    required this.child,
    required this.message,
  }) : super(key: key);

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static MessageWidgetState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMessageContainer>()
        ?.data;
  }

  @override
  MessageWidgetState createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget> {
  Message get message => widget.message;

  void updateMime({MimeMessage? mime}) {
    message.updateMime(mime);
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedMessageContainer(
      data: this,
      child: widget.child,
    );
  }
}
