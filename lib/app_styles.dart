// import 'package:enough_style/enough_style.dart';
// import 'package:flutter/material.dart';

// class AppStyles {
//   static AppStyles instance = AppStyles._();
//   StyleSheetManager styleSheetManager = StyleSheetManager.instance;

//   AppStyles._() {
//     var defaultPrimarySwatch = Colors.green;
//     var brightColorScheme = ColorScheme.fromSwatch(
//         primarySwatch: defaultPrimarySwatch,
//         backgroundColor: Color(0xfff0f0f0),
//         errorColor: Colors.redAccent,
//         brightness: Brightness.light);
//     var darkColorScheme = ColorScheme.fromSwatch(
//         primarySwatch: defaultPrimarySwatch,
//         backgroundColor: Color(0xff3a3a3a),
//         errorColor: Colors.redAccent,
//         brightness: Brightness.dark);
//     var chocoladeColorScheme = ColorScheme.fromSwatch(
//         primarySwatch: Colors.brown,
//         backgroundColor: Colors.brown[600],
//         errorColor: Colors.redAccent,
//         brightness: Brightness.dark);
//     var neomorphismBright = StyleSheet('neo bright',
//         themeData: ThemeData(
//             colorScheme: brightColorScheme,
//             primarySwatch: defaultPrimarySwatch));
//     neomorphismBright.addStyle(
//         Style('page', padding: EdgeInsets.all(20), decorator: FlatDecorator()));
//     neomorphismBright.addStyle(Style('settings',
//         decorator: NeomorphismDecorator(
//             borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(50),
//                 bottomLeft: Radius.circular(50))),
//         padding: EdgeInsets.all(20),
//         margin: EdgeInsets.fromLTRB(10, 0, 10, 0)));
//     neomorphismBright.addStyle(Style('settingsOption',
//         textStyler: NeomorphismTextStyler(
//             color: const Color(0xff3A3A3A),
//             textStyle: TextStyle(fontWeight: FontWeight.bold))));
//     styleSheetManager.add(neomorphismBright);
//     styleSheetManager
//         .add(neomorphismBright.copyWith('neo dark', darkColorScheme));
//     styleSheetManager
//         .add(neomorphismBright.copyWith('neo chocolade', chocoladeColorScheme));
//   }
// }
