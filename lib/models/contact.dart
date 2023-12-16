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
  // TODO(RV): consider full vCard support
}
