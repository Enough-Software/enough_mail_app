import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_media/enough_media.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../app_lifecycle/provider.dart';
import '../keys/service.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../routes/routes.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import 'ical_composer.dart';
import 'icon_text.dart';

class _AttachmentMediaProviderFactory {
  static MediaProvider fromAttachmentInfo(AttachmentInfo info) =>
      MemoryMediaProvider(
        info.name ?? '',
        info.mediaType.text,
        info.data ?? Uint8List(0),
      );
}

/// Allows to add attachments to a [ComposeData]
class AttachmentComposeBar extends StatefulWidget {
  /// Creates a new [AttachmentComposeBar]
  const AttachmentComposeBar({
    super.key,
    required this.composeData,
    this.isDownloading = false,
  });

  /// The associated [ComposeData]
  final ComposeData composeData;

  /// Set to true if the attachments are currently downloading
  final bool isDownloading;

  @override
  State<AttachmentComposeBar> createState() => _AttachmentComposeBarState();
}

class _AttachmentComposeBarState extends State<AttachmentComposeBar> {
  late List<AttachmentInfo> _attachments;

  @override
  void initState() {
    _attachments = widget.composeData.messageBuilder.attachments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Wrap(
        children: [
          for (final attachment in _attachments)
            _ComposeAttachment(
              parentMessage: widget.composeData.originalMessage,
              attachment: attachment,
              onRemove: removeAttachment,
            ),
          if (widget.isDownloading) const PlatformProgressIndicator(),
          AddAttachmentPopupButton(
            composeData: widget.composeData,
            update: () => setState(() {}),
          ),
        ],
      );

  void removeAttachment(AttachmentInfo attachment) {
    widget.composeData.messageBuilder.removeAttachment(attachment);
    setState(() {
      _attachments.remove(attachment);
    });
  }
}

class AddAttachmentPopupButton extends ConsumerWidget {
  const AddAttachmentPopupButton({
    super.key,
    required this.composeData,
    required this.update,
  });
  final ComposeData composeData;
  final Function() update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void ignoreNextResume() => ref
        .read(appLifecycleProvider.notifier)
        .ignoreNextInactivationCycle(timeout: const Duration(seconds: 120));

    final localizations = ref.text;
    final iconService = IconService.instance;
    const brightness = Brightness.light;
    // TODO(RV): implement brightness access
    // themeService.brightness(context);

    return PlatformPopupMenuButton<int>(
      icon: Icon(CommonPlatformIcons.add),
      itemBuilder: (context) => [
        PlatformPopupMenuItem(
          value: 0,
          child: IconText(
            icon: Icon(iconService.mediaFile),
            label: Text(localizations.attachTypeFile),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 1,
          child: IconText(
            icon: Icon(iconService.mediaPhoto),
            label: Text(localizations.attachTypePhoto),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 2,
          child: IconText(
            icon: Icon(iconService.mediaVideo),
            label: Text(localizations.attachTypeVideo),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 3,
          child: IconText(
            icon: Icon(iconService.mediaAudio),
            label: Text(localizations.attachTypeAudio),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 4,
          child: IconText(
            icon: Icon(iconService.location),
            label: Text(localizations.attachTypeLocation),
            brightness: brightness,
          ),
        ),
        if (KeyService.instance.hasGiphy)
          PlatformPopupMenuItem(
            value: 5,
            child: IconText(
              icon: Icon(iconService.mediaGif),
              label: Text(localizations.attachTypeGif),
              brightness: brightness,
            ),
          ),
        PlatformPopupMenuItem(
          value: 6,
          child: IconText(
            icon: Icon(iconService.appointment),
            label: Text(localizations.attachTypeAppointment),
            brightness: brightness,
          ),
        ),
      ],
      onSelected: (value) async {
        var changed = false;
        switch (value) {
          case 0: // any file
            ignoreNextResume();
            changed = await _addAttachmentFile();
            break;
          case 1: // photo file
            ignoreNextResume();
            changed = await _addAttachmentFile(
              fileType: FileType.image,
            );
            break;
          case 2: // video file
            ignoreNextResume();
            changed = await _addAttachmentFile(
              fileType: FileType.video,
            );
            break;
          case 3: // audio file
            ignoreNextResume();
            changed = await _addAttachmentFile(
              fileType: FileType.audio,
            );
            break;
          case 4: // location
            if (context.mounted) {
              final result =
                  await context.pushNamed<Uint8List>(Routes.locationPicker);
              if (result != null) {
                composeData.messageBuilder.addBinary(
                  result,
                  MediaSubtype.imagePng.mediaType,
                  filename: 'location.jpg',
                );
                changed = true;
              }
            }
            break;
          case 5: // gif / sticker / emoji file
            if (context.mounted) {
              changed = await addAttachmentGif(ref, localizations);
            }
            break;
          case 6: // appointment
            if (context.mounted) {
              changed =
                  await addAttachmentAppointment(context, ref, localizations);
            }
            break;
        }
        if (changed) {
          update();
        }
      },
    );
  }

  Future<bool> _addAttachmentFile({
    FileType fileType = FileType.any,
  }) async {
    final result = await FilePicker.platform
        .pickFiles(type: fileType, allowMultiple: true, withData: true);
    if (result == null) {
      return false;
    }
    for (final file in result.files) {
      final path = file.path;
      final bytes = file.bytes;
      if (path == null || bytes == null) {
        continue;
      }
      final lastDotIndex = path.lastIndexOf('.');
      MediaType mediaType;
      if (lastDotIndex == -1 || lastDotIndex == path.length - 1) {
        mediaType = MediaType.fromSubtype(MediaSubtype.applicationOctetStream);
      } else {
        final ext = path.substring(lastDotIndex + 1);
        mediaType = MediaType.guessFromFileExtension(ext);
      }
      composeData.messageBuilder
          .addBinary(bytes, mediaType, filename: file.name);
    }

    return true;
  }

  Future<bool> addAttachmentGif(
    WidgetRef ref,
    AppLocalizations localizations,
  ) async {
    final giphy = KeyService.instance.giphy;
    if (giphy == null) {
      await LocalizedDialogHelper.showTextDialog(
        ref,
        localizations.errorTitle,
        'No GIPHY API key found. Please check set up instructions.',
      );

      return false;
    }

    final gif = await Giphy.getGif(
      context: ref.context,
      apiKey: giphy,
      // searchLabelText: searchSticker
      //     ? localizations.attachTypeStickerSearch
      //     : localizations.attachTypeGifSearch,
      lang: localizations.localeName,
      keepState: true,
      showPreview: true,
      // sticker: searchSticker,
      // showPreviewPage: false,
    );
    final contentUrl = gif?.recommendedMobileSend.url;
    if (gif == null || contentUrl == null) {
      return false;
    }
    final response = await http.get(Uri.parse(contentUrl));
    if (response.statusCode != 200) {
      return false;
    }
    final data = response.bodyBytes;
    composeData.messageBuilder.addBinary(
      data,
      MediaType.fromSubtype(MediaSubtype.imageGif),
      filename: '${gif.title}.gif',
    );

    return true;
  }

  Future<bool> addAttachmentAppointment(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) async {
    final appointment =
        await IcalComposer.createOrEditAppointment(context, ref);
    if (appointment != null) {
      // idea: add some sort of finalizer that updates the appointment
      // at the end to set the organizer and the attendees
      final text = appointment.toString();
      final attachmentBuilder = composeData.messageBuilder.addText(
        text,
        mediaType: MediaType.fromText('application/ics'),
        disposition: ContentDispositionHeader.from(
          ContentDisposition.attachment,
          filename: 'invite.ics',
        ),
      );
      attachmentBuilder.contentType?.setParameter('method', 'REQUEST');
      final finalizer = _AppointmentFinalizer(appointment, attachmentBuilder);
      composeData.addFinalizer(finalizer.finalize);
    }

    return (appointment != null);
  }
}

class _AppointmentFinalizer {
  _AppointmentFinalizer(this.appointment, this.attachmentBuilder);
  final VCalendar appointment;
  final PartBuilder attachmentBuilder;

  void finalize(MessageBuilder messageBuilder) {
    final event = appointment.event;
    if (event == null) {
      return;
    }
    void addAttendee({
      required String email,
      required String? name,
      bool rsvp = true,
      ParticipantStatus? participantStatus,
    }) {
      final attendeeProperty = AttendeeProperty.create(
        attendeeEmail: email,
        commonName: name,
        rsvp: rsvp,
        participantStatus: participantStatus,
      );
      if (attendeeProperty != null) {
        event.addAttendee(attendeeProperty);
      }
    }

    final from = messageBuilder.from;
    if (from != null && from.isNotEmpty) {
      final organizer = from.first;
      event.organizer = OrganizerProperty.create(
        email: organizer.email,
        commonName: organizer.personalName,
      );
      addAttendee(
        email: organizer.email,
        name: organizer.personalName,
        rsvp: false,
        participantStatus: ParticipantStatus.accepted,
      );
    }
    final recipients = <MailAddress>[];
    void addRecipients(List<MailAddress>? addresses) {
      if (addresses != null) {
        recipients.addAll(addresses);
      }
    }

    addRecipients(messageBuilder.to);
    addRecipients(messageBuilder.cc);
    for (final mailAddress in recipients) {
      addAttendee(email: mailAddress.email, name: mailAddress.personalName);
    }
    attachmentBuilder.text = appointment.toString();
  }
}

class _ComposeAttachment extends ConsumerWidget {
  const _ComposeAttachment({
    required this.parentMessage,
    required this.attachment,
    required this.onRemove,
  });

  final Message? parentMessage;
  final AttachmentInfo attachment;
  final void Function(AttachmentInfo attachment) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final parentMessage = this.parentMessage;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: PreviewMediaWidget(
          mediaProvider:
              _AttachmentMediaProviderFactory.fromAttachmentInfo(attachment),
          width: 60,
          height: 60,
          showInteractiveDelegate: (interactiveMedia) async {
            final attachmentData = attachment.data;
            if (attachment.mediaType.sub == MediaSubtype.messageRfc822 &&
                parentMessage != null &&
                attachmentData != null) {
              final mime = MimeMessage.parseFromData(attachmentData);
              final message = Message.embedded(mime, parentMessage);

              return context.pushNamed(
                Routes.mailDetails,
                extra: message,
              );
            }
            final attachmentText = attachment.part.text;
            if (attachmentText != null &&
                (attachment.mediaType.sub == MediaSubtype.applicationIcs ||
                    attachment.mediaType.sub == MediaSubtype.textCalendar)) {
              final appointment = VComponent.parse(attachmentText) as VCalendar;
              final update = await IcalComposer.createOrEditAppointment(
                context,
                ref,
                appointment: appointment,
              );
              if (update != null) {
                attachment.part.text = update.toString();
              }

              return Future.value();
            }

            return context.pushNamed(
              Routes.interactiveMedia,
              extra: interactiveMedia,
            );
          },
          contextMenuEntries: [
            PopupMenuItem<String>(
              value: 'remove',
              child: Text(
                localizations.composeRemoveAttachmentAction(
                  attachment.name ?? '',
                ),
              ),
            ),
          ],
          onContextMenuSelected: (provider, value) => onRemove(attachment),
        ),
      ),
    );
  }
}
