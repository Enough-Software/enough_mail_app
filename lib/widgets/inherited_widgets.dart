import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:flutter/cupertino.dart';

class _InheritedMessageContainer extends InheritedWidget {
  // You must pass through a child and your state.
  const _InheritedMessageContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final MessageWidgetState data;
  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedMessageContainer old) => (old.data != data);
}

class MessageWidget extends StatefulWidget {
  // You must pass through a child.
  final Widget child;
  final Message? message;

  const MessageWidget({
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
  Message? get message => widget.message;

  void updateMime({required MimeMessage mime}) {
    message?.updateMime(mime);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedMessageContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedMessageSourceContainer extends InheritedWidget {
  final MessageSourceWidgetState data;

  // You must pass through a child and your state.
  const _InheritedMessageSourceContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedMessageSourceContainer old) =>
      (old.data != data);
}

class MessageSourceWidget extends StatefulWidget {
  const MessageSourceWidget({
    Key? key,
    required this.child,
    required this.messageSource,
  }) : super(key: key);

  // You must pass through a child.
  final Widget child;
  final MessageSource? messageSource;

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static MessageSourceWidgetState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMessageSourceContainer>()
        ?.data;
  }

  @override
  MessageSourceWidgetState createState() => MessageSourceWidgetState();
}

class MessageSourceWidgetState extends State<MessageSourceWidget> {
  MessageSource? get messageSource => widget.messageSource;

  @override
  Widget build(BuildContext context) {
    return _InheritedMessageSourceContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedMailServiceContainer extends InheritedWidget {
  final MailServiceWidgetState data;

  // You must pass through a child and your state.
  const _InheritedMailServiceContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedMailServiceContainer old) => true;
  //(old.data._account != data._account);
}

class MailServiceWidget extends StatefulWidget {
  final Widget child;
  final Account? account;
  final List<Account>? accounts;
  final MessageSource? messageSource;

  const MailServiceWidget({
    Key? key,
    required this.child,
    required this.account,
    required this.accounts,
    required this.messageSource,
  }) : super(key: key);

  static MailServiceWidgetState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMailServiceContainer>()
        ?.data;
  }

  @override
  MailServiceWidgetState createState() => MailServiceWidgetState();
}

class MailServiceWidgetState extends State<MailServiceWidget> {
  Account? _account;
  List<Account>? _accounts;
  MessageSource? _messageSource;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _accounts = widget.accounts;
    _messageSource = widget.messageSource;
  }

  Account? get account => _account;
  set account(Account? value) {
    setState(() {
      _account = value;
    });
  }

  List<Account>? get accounts => _accounts;
  set accounts(List<Account>? value) {
    setState(() {
      _accounts = value;
    });
  }

  MessageSource? get messageSource => _messageSource;
  set messageSource(MessageSource? value) {
    setState(() {
      _messageSource = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedMailServiceContainer(
      data: this,
      child: widget.child,
    );
  }
}
