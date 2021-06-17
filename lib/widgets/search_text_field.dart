import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

/// A dedicated search field optimized for Cupertino
class SearchTextField extends StatefulWidget {
  final MessageSource messageSource;
  SearchTextField({Key? key, required this.messageSource}) : super(key: key);

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
        locator<NavigationService>().push(
          Routes.search,
          arguments: widget.messageSource,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.messageSource,
      child: CupertinoSearchTextField(
        focusNode: _focusNode,
      ),
    );
  }
}
