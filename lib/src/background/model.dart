import 'dart:convert';

/// Contains information about a known message UIDs for each email account
class BackgroundUpdateInfo {
  /// Creates info for the background update
  BackgroundUpdateInfo({required Map<String, int> uidsByEmail})
      : _uidsByEmail = uidsByEmail;

  /// Creates info from the given [json]
  factory BackgroundUpdateInfo.fromJson(Map<String, dynamic> json) {
    final uidsJsonText = json['uidsByEmail'];
    final uidsByEmail = uidsJsonText is String
        ? (jsonDecode(uidsJsonText) as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value as int),
          )
        : <String, int>{};

    return BackgroundUpdateInfo(uidsByEmail: uidsByEmail);
  }

  /// Creates info from the given [jsonText]
  factory BackgroundUpdateInfo.fromJsonText(String? jsonText) =>
      jsonText == null
          ? BackgroundUpdateInfo(uidsByEmail: <String, int>{})
          : BackgroundUpdateInfo.fromJson(jsonDecode(jsonText));

  /// Converts this info to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'uidsByEmail': jsonEncode(_uidsByEmail),
      };

  final Map<String, int> _uidsByEmail;

  var _isDirty = false;

  /// Has this information been updated since the last persistence?
  bool get containsUpdatedEntries => _isDirty;

  /// Updates the entry for the given [email]
  void updateForEmail(String email, int nextExpectedUid) {
    final uidsByEmail = _uidsByEmail;
    if (uidsByEmail[email] != nextExpectedUid) {
      uidsByEmail[email] = nextExpectedUid;
      _isDirty = true;
    }
  }

  /// Retrieves the next expected uid
  int? nextExpectedUidForEmail(String email) => _uidsByEmail[email];
}
