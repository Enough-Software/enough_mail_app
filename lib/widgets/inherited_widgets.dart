import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
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
  final Message? message;

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
  _InheritedMessageSourceContainer({
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
  // You must pass through a child.
  final Widget child;
  final MessageSource? messageSource;

  MessageSourceWidget({
    Key? key,
    required this.child,
    required this.messageSource,
  }) : super(key: key);

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

class _InheritedAccountContainer extends InheritedWidget {
  final AccountWidgetState data;

  // You must pass through a child and your state.
  _InheritedAccountContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedAccountContainer old) => (old.data != data);
}

class AccountWidget extends StatefulWidget {
  // You must pass through a child.
  final Widget child;
  final Account? account;

  AccountWidget({
    Key? key,
    required this.child,
    required this.account,
  }) : super(key: key);

  static AccountWidgetState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAccountContainer>()
        ?.data;
  }

  @override
  AccountWidgetState createState() => AccountWidgetState();
}

class AccountWidgetState extends State<AccountWidget> {
  Account? _account;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  Account? get account => _account;
  set account(Account? value) {
    setState(() {
      _account = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAccountContainer(
      data: this,
      child: widget.child,
    );
  }
}
