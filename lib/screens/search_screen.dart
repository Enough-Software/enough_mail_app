import 'package:flutter/cupertino.dart';

/// Search input screen, currently used only for Cupertino
class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoSearchTextField(),
        CupertinoDialogAction(child: Text(cancel))
      ],
    );
  }
}
