import 'package:enough_mail/enough_mail.dart';
import 'package:enough_serialization/enough_serialization.dart';

class Group extends SerializableObject {
  String? get name => attributes['name'];
  set name(String? value) => attributes['name'] = value;
  Group({String? groupName}) {
    name = groupName;
  }
}

class Contact extends SerializableObject {
  String? get name => attributes['name'];
  set name(String? value) => attributes['name'] = value;
  List<MailAddress>? get mailAddresses => attributes['mailAddresses'];
  set mailAddresses(List<MailAddress>? value) =>
      attributes['mailAddresses'] = value;
  DateTime? get birthday => attributes['birthday'];
  set birthday(DateTime? value) => attributes['birthday'] = value;
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
