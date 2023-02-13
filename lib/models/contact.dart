import 'package:enough_mail/enough_mail.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@JsonSerializable()
class Group {
  const Group({required this.name});

  final String name;
}

@JsonSerializable()
class Contact {
  const Contact({
    required this.name,
    required this.mailAddresses,
    this.birthday,
  });

  final String name;

  final List<MailAddress> mailAddresses;
  final DateTime? birthday;
  //phone numbers, profile photo(s),
  //TODO consider full vCard support
}

class ContactManager {
  final List<MailAddress> addresses;
  ContactManager(this.addresses);

  Iterable<MailAddress> find(String search) {
    return addresses.where((address) =>
        address.email.contains(search) ||
        (address.hasPersonalName && address.personalName!.contains(search)));
  }
}
