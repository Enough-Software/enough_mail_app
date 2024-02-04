import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../account/model.dart';

/// Contains information about a sender for composing new messages
@immutable
class Sender {
  /// Creates a new sender
  Sender(
    this.address,
    this.account, {
    this.isPlaceHolderForPlusAlias = false,
  }) : emailLowercase = address.email.toLowerCase();

  /// The address
  final MailAddress address;

  /// The associated account
  final RealAccount account;

  /// Whether this sender is a placeholder for a plus alias
  final bool isPlaceHolderForPlusAlias;

  /// The lowercase email address for comparisons
  final String emailLowercase;

  @override
  String toString() => address.toString();

  @override
  int get hashCode => emailLowercase.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Sender && other.emailLowercase == emailLowercase;
}
