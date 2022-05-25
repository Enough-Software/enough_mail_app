import 'dart:convert';

import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:enough_icalendar_export/enough_icalendar_export.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/mail_address_chip.dart';
import 'package:enough_mail_app/widgets/text_with_links.dart';
import 'package:enough_mail_icalendar/enough_mail_icalendar.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import 'package:collection/collection.dart' show IterableExtension;

class IcalInteractiveMedia extends StatefulWidget {
  final MediaProvider mediaProvider;
  final Message message;
  const IcalInteractiveMedia(
      {Key? key, required this.mediaProvider, required this.message})
      : super(key: key);

  @override
  State<IcalInteractiveMedia> createState() => _IcalInteractiveMediaState();
}

class _IcalInteractiveMediaState extends State<IcalInteractiveMedia> {
  VCalendar? _calendar;
  VEvent? _event;
  bool _isPermanentError = false;
  bool _canReply = false;
  ParticipantStatus? _participantStatus;

  @override
  void initState() {
    super.initState();
    final provider = widget.mediaProvider;
    try {
      if (provider is TextMediaProvider) {
        _calendar = VComponent.parse(provider.text) as VCalendar;
      } else if (provider is MemoryMediaProvider) {
        _calendar =
            VComponent.parse(utf8.decode(provider.data, allowMalformed: true))
                as VCalendar;
      }
      _canReply = _calendar?.canReply ?? false;
      _event = _calendar?.event;
      if (_event == null) {
        _isPermanentError = true;
      } else {
        _participantStatus =
            widget.message.mimeMessage.calendarParticipantStatus;
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to parse text/calendar format: $e $s');
      }
      _isPermanentError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final event = _calendar?.event;
    if (event == null) {
      if (_isPermanentError) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(localizations.errorTitle),
        );
      }
      return const Center(child: PlatformProgressIndicator());
    }
    final isReply = _calendar?.method == Method.reply;
    final attendees = isReply ? <AttendeeProperty>[] : event.attendees;
    final i18nService = locator<I18nService>();
    final userEmail = widget.message.account.email.toLowerCase();
    final recurrenceRule = event.recurrenceRule;
    var end = event.end;
    var start = event.start;
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (isReply)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildReply(context, localizations, event),
              )
            else if (_canReply && _participantStatus == null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PlatformTextButton(
                    child: PlatformText(localizations.actionAccept),
                    onPressed: () => _changeParticipantStatus(
                        ParticipantStatus.accepted, localizations),
                  ),
                  PlatformTextButton(
                    child:
                        PlatformText(localizations.icalendarAcceptTentatively),
                    onPressed: () => _changeParticipantStatus(
                        ParticipantStatus.tentative, localizations),
                  ),
                  PlatformTextButton(
                    child: PlatformText(localizations.actionDecline),
                    onPressed: () => _changeParticipantStatus(
                        ParticipantStatus.declined, localizations),
                  ),
                ],
              )
            else if (_participantStatus != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        _participantStatus?.localization(localizations) ?? ''),
                  ),
                  PlatformTextButton(
                    child: PlatformText(
                        localizations.icalendarActionChangeParticipantStatus),
                    onPressed: () => _queryParticipantStatus(localizations),
                  ),
                ],
              ),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth()
              },
              children: [
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(localizations.icalendarLabelSummary),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextWithLinks(
                        text: event.summary ??
                            localizations.icalendarNoSummaryInfo),
                  )
                ]),
                if (start != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelStart),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          i18nService.formatDateTime(start.toLocal(),
                              alwaysUseAbsoluteFormat: true,
                              useLongFormat: true),
                        ),
                      )
                    ],
                  ),
                if (end != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelEnd),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          i18nService.formatDateTime(end.toLocal(),
                              alwaysUseAbsoluteFormat: true,
                              useLongFormat: true),
                        ),
                      ),
                    ],
                  )
                else if (event.duration != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelDuration),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            i18nService.formatIsoDuration(event.duration!)),
                      )
                    ],
                  ),
                if (recurrenceRule != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelRecurrenceRule),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(recurrenceRule.toHumanReadableText(
                          languageCode: localizations.localeName,
                        )),
                      )
                    ],
                  ),
                if (event.description != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelDescription),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextWithLinks(
                          text: event.description!,
                        ),
                      ),
                    ],
                  ),
                if (event.location != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelLocation),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextWithLinks(text: event.location!),
                      )
                    ],
                  ),
                if (event.microsoftTeamsMeetingUrl != null)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelTeamsUrl),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextWithLinks(
                            text: event.microsoftTeamsMeetingUrl!),
                      )
                    ],
                  ),
                if (attendees.isNotEmpty)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.icalendarLabelParticipants),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: attendees.map((attendee) {
                          final isMe =
                              attendee.email?.toLowerCase() == userEmail;
                          final address = isMe
                              ? widget.message.account.fromAddress
                              : attendee.mailAddress;
                          final participantStatus = (isMe)
                              ? _participantStatus ?? attendee.participantStatus
                              : attendee.participantStatus;
                          final icon = participantStatus?.icon;
                          final name = isMe
                              ? widget.message.account.userName ??
                                  attendee.commonName
                              : attendee.commonName;
                          final textStyle = participantStatus?.textStyle;
                          return Row(
                            children: [
                              if (icon != null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: icon,
                                ),
                              address != null
                                  ? MailAddressChip(mailAddress: address)
                                  : Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (name != null)
                                              Text(
                                                name,
                                                style: textStyle,
                                              ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Text(
                                                attendee.email ??
                                                    attendee.uri.toString(),
                                                style: textStyle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
            if (!isReply)
              PlatformElevatedButton(
                child: PlatformText(localizations.icalendarExportAction),
                onPressed: () => _exportToNativeCalendar(_calendar),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToNativeCalendar(VCalendar? calendar) async {
    if (calendar == null) {
      if (kDebugMode) {
        print('Warning: no calendar to export.');
      }
      return;
    }
    try {
      await calendar.exportToNativeCalendar();
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to export calendar: $e $s');
      }
    }
  }

  Future<void> _changeParticipantStatus(
      ParticipantStatus status, AppLocalizations localizations) async {
    setState(() {
      _participantStatus = status;
    });
    try {
      widget.message.mailClient.sendCalendarReply(
        _calendar!,
        status,
        originatingMessage: widget.message.mimeMessage,
        productId: 'Maily',
      );
      locator<ScaffoldMessengerService>()
          .showTextSnackBar(status.localization(localizations));
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to send status update: $e $s');
      }
      LocalizedDialogHelper.showTextDialog(context, localizations.errorTitle,
          localizations.icalendarParticipantStatusSentFailure(e.toString()));
    }
  }

  void _queryParticipantStatus(AppLocalizations localizations) async {
    final status = await LocalizedDialogHelper.showTextDialog(
        context,
        localizations.icalendarParticipantStatusChangeTitle,
        localizations.icalendarParticipantStatusChangeText,
        actions: [
          PlatformTextButton(
            child: PlatformText(localizations.actionAccept),
            onPressed: () =>
                Navigator.of(context).pop(ParticipantStatus.accepted),
          ),
          PlatformTextButton(
            child: PlatformText(localizations.icalendarAcceptTentatively),
            onPressed: () =>
                Navigator.of(context).pop(ParticipantStatus.tentative),
          ),
          PlatformTextButton(
            child: PlatformText(localizations.actionDecline),
            onPressed: () =>
                Navigator.of(context).pop(ParticipantStatus.declined),
          ),
          PlatformTextButton(
            child: PlatformText(localizations.actionCancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ]);
    if (status != null && status != _participantStatus) {
      _changeParticipantStatus(status, localizations);
    }
  }

  Widget _buildReply(
      BuildContext context, AppLocalizations localizations, VEvent event) {
    // This is a reply from one of the participants:
    var attendees = event.attendees;
    if (attendees.isEmpty) {
      return Text(localizations.icalendarReplyWithoutParticipants);
    }
    final fromEmail = widget.message.mimeMessage.fromEmail;
    if (attendees.length > 1) {
      final attendee = attendees.firstWhereOrNull((a) => a.email == fromEmail);
      if (attendee != null) {
        attendees = [attendee];
      }
    }
    // This should be the most common situation:
    final attendee = attendees.first;
    final status = attendee.participantStatus;
    if (status == null) {
      return Text(localizations
          .icalendarReplyWithoutStatus(attendee.mailAddress.toString()));
    }
    return Text(
      status.participantReplyText(
          localizations, attendee.mailAddress.toString()),
      style: const TextStyle(fontStyle: FontStyle.italic),
    );
  }
}

extension ExtensionParticipantStatusTextStyle on ParticipantStatus {
  // static const TextStyle _styleAccepted = const TextStyle(color: Colors.green);
  static const TextStyle _styleDeclined =
      TextStyle(color: Colors.red, decorationStyle: TextDecorationStyle.dashed);
  static const TextStyle _styleTentative =
      TextStyle(fontStyle: FontStyle.italic);

  TextStyle? get textStyle {
    switch (this) {
      case ParticipantStatus.needsAction:
        return null;
      case ParticipantStatus.accepted:
        return null; //_styleAccepted;
      case ParticipantStatus.declined:
        return _styleDeclined;
      case ParticipantStatus.tentative:
        return _styleTentative;
      case ParticipantStatus.delegated:
        return null;
      case ParticipantStatus.inProcess:
        return null;
      case ParticipantStatus.partial:
        return null;
      case ParticipantStatus.completed:
        return null;
      case ParticipantStatus.other:
        return null;
    }
  }

  Icon? get icon {
    switch (this) {
      case ParticipantStatus.needsAction:
        return null;
      case ParticipantStatus.accepted:
        return Icon(
          CommonPlatformIcons.ok,
          color: Colors.green,
        );
      case ParticipantStatus.declined:
        return Icon(CommonPlatformIcons.cancel);
      case ParticipantStatus.tentative:
        return Icon(PlatformInfo.isCupertino
            ? CupertinoIcons.question
            : Icons.question_answer);
      case ParticipantStatus.delegated:
        return null;
      case ParticipantStatus.inProcess:
        return null;
      case ParticipantStatus.partial:
        return null;
      case ParticipantStatus.completed:
        return null;
      case ParticipantStatus.other:
        return null;
    }
  }

  String localization(AppLocalizations localizations) {
    switch (this) {
      case ParticipantStatus.needsAction:
        return localizations.icalendarParticipantStatusNeedsAction;
      case ParticipantStatus.accepted:
        return localizations.icalendarParticipantStatusAccepted;
      case ParticipantStatus.declined:
        return localizations.icalendarParticipantStatusDeclined;
      case ParticipantStatus.tentative:
        return localizations.icalendarParticipantStatusAcceptedTentatively;
      case ParticipantStatus.delegated:
        return localizations.icalendarParticipantStatusDelegated;
      case ParticipantStatus.inProcess:
        return localizations.icalendarParticipantStatusInProcess;
      case ParticipantStatus.partial:
        return localizations.icalendarParticipantStatusPartial;
      case ParticipantStatus.completed:
        return localizations.icalendarParticipantStatusCompleted;
      case ParticipantStatus.other:
        return localizations.icalendarParticipantStatusOther;
    }
  }

  String participantReplyText(AppLocalizations localizations, String attendee) {
    switch (this) {
      case ParticipantStatus.needsAction:
        return localizations.icalendarReplyStatusNeedsAction(attendee);
      case ParticipantStatus.accepted:
        return localizations.icalendarReplyStatusAccepted(attendee);
      case ParticipantStatus.declined:
        return localizations.icalendarReplyStatusDeclined(attendee);
      case ParticipantStatus.tentative:
        return localizations.icalendarReplyStatusAcceptedTentatively(attendee);
      case ParticipantStatus.delegated:
        return localizations.icalendarReplyStatusDelegated(attendee);
      case ParticipantStatus.inProcess:
        return localizations.icalendarReplyStatusInProcess(attendee);
      case ParticipantStatus.partial:
        return localizations.icalendarReplyStatusPartial(attendee);
      case ParticipantStatus.completed:
        return localizations.icalendarReplyStatusCompleted(attendee);
      case ParticipantStatus.other:
        return localizations.icalendarReplyStatusOther(attendee);
    }
  }
}
