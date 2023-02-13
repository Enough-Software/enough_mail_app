import 'package:enough_mail/enough_mail.dart';
import 'package:json_annotation/json_annotation.dart';

part 'background_update_info.g.dart';

@JsonSerializable()
class BackgroundUpdateInfo {
  BackgroundUpdateInfo({Map<String, int>? uidsByEmail})
      : _uidsByEmail = uidsByEmail;

  factory BackgroundUpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$BackgroundUpdateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundUpdateInfoToJson(this);

  @JsonKey(name: 'uidsByEmail')
  Map<String, int>? _uidsByEmail;

  @JsonKey(ignore: true)
  var _isDirty = false;

  /// Has this information been updated since the last persistence?
  bool get isDirty => _isDirty;

  void updateForClient(MailClient mailClient, int nextExpectedUid) =>
      updateForEmail(mailClient.account.email, nextExpectedUid);

  void updateForEmail(String email, int nextExpectedUid) {
    final uidsByEmail = _uidsByEmail ?? <String, int>{};
    uidsByEmail[email] = nextExpectedUid;
    _isDirty = true;
    _uidsByEmail = uidsByEmail;
  }

  /// Retrieves the next expected uid
  int? nextExpectedUidForClient(MailClient mailClient) =>
      nextExpectedUidForEmail(mailClient.account.email);

  /// Retrieves the next expected uid
  int? nextExpectedUidForAccount(MailAccount account) =>
      nextExpectedUidForEmail(account.email);

  /// Retrieves the next expected uid
  int? nextExpectedUidForEmail(String email) {
    final uidsByEmail = _uidsByEmail;
    if (uidsByEmail == null) {
      return null;
    }
    return uidsByEmail[email];
  }
}
