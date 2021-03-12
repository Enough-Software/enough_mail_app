import 'package:enough_mail_app/models/message_source.dart';

class UnifiedMessageSourceChangedEvent {
  final MessageSource messageSource;
  UnifiedMessageSourceChangedEvent(this.messageSource);
}
