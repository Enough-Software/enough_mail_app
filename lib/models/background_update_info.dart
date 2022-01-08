import 'package:enough_mail/enough_mail.dart';
import 'package:enough_serialization/enough_serialization.dart';

class BackgroundUpdateInfo extends SerializableObject {
  BackgroundUpdateInfo() {
    objectCreators['uidsByEmail'] = (map) => <String, int>{};
  }

  Map<String, int>? get _uidsByEmail => attributes['uidsByEmail'];
  set _uidsByEmail(Map<String, int>? value) =>
      attributes['uidsByEmail'] = value;

  var _isDirty = false;

  /// Has this information been updated since the last persistence?
  bool get isDirty => _isDirty;

  void updateForClient(MailClient mailClient, int nextExpectedUid) =>
      updateForEmail(mailClient.account.email ?? '', nextExpectedUid);

  void updateForEmail(String email, int nextExpectedUid) {
    final uidsByEmail = _uidsByEmail ?? <String, int>{};
    uidsByEmail[email] = nextExpectedUid;
    _isDirty = true;
    _uidsByEmail = uidsByEmail;
  }

  /// Retrieves the next expected uid
  int? nextExpectedUidForClient(MailClient mailClient) =>
      nextExpectedUidForEmail(mailClient.account.email ?? '');

  /// Retrieves the next expected uid
  int? nextExpectedUidForAccount(MailAccount account) =>
      nextExpectedUidForEmail(account.email ?? '');

  /// Retrieves the next expected uid
  int? nextExpectedUidForEmail(String email) {
    final uidsByEmail = _uidsByEmail;
    if (uidsByEmail == null) {
      return null;
    }
    return uidsByEmail[email];
  }
}
