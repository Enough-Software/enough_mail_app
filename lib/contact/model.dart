import 'package:enough_mail/enough_mail.dart';

/// Contains a list of a contacts for a given account
class ContactManager {
  /// Creates a new [ContactManager] with the given [addresses
  ContactManager(this.addresses);

  /// The list of addresses
  final List<MailAddress> addresses;

  /// Finds the addresses matching the given [search]
  Iterable<MailAddress> find(String search) => addresses.where(
        (address) =>
            address.email.contains(search) ||
            (address.hasPersonalName &&
                (address.personalName ?? '').contains(search)),
      );
}
