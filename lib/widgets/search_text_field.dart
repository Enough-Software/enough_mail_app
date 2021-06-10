import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  SearchTextField({Key key}) : super(key: key);

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _focusNode.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
