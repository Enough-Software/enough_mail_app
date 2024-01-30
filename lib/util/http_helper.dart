import 'dart:convert';

import 'package:http/http.dart';

/// Extension methods for [Response]
extension HttpResponseExtension on Response {
  /// Retrieves the UTF8 decoded text
  String? get text => utf8.decode(bodyBytes);
}
