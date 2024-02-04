import 'dart:io';
import 'dart:typed_data';

import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail/enough_mail.dart';

/// State of a shared data item
enum SharedDataAddState {
  /// The item was added
  added,

  /// The item was not added
  notAdded,
}

/// Result of adding a shared data item
class SharedDataAddResult {
  /// Creates a new [SharedDataAddResult]
  const SharedDataAddResult(this.state, [this.details]);

  /// The item was added
  static const added = SharedDataAddResult(SharedDataAddState.added);

  /// The item was not added
  static const notAdded = SharedDataAddResult(SharedDataAddState.notAdded);

  /// The state of the item
  final SharedDataAddState state;

  /// The details of the item
  final dynamic details;
}

/// Shared data item
abstract class SharedData {
  /// Creates a new [SharedData]
  SharedData(this.mediaType);

  /// The media type of the item, e.g. `image/jpeg`
  final MediaType mediaType;

  /// Adds the item to the message builder
  Future<SharedDataAddResult> addToMessageBuilder(MessageBuilder builder);

  /// Adds the item to the editor
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi);
}

/// Shared data item for a file
class SharedFile extends SharedData {
  /// Creates a new [SharedFile]
  SharedFile(this.file, MediaType? mediaType)
      : super(mediaType ?? MediaType.guessFromFileName(file.path));

  /// The file
  final File file;

  @override
  Future<SharedDataAddResult> addToMessageBuilder(
    MessageBuilder builder,
  ) async {
    await builder.addFile(file, mediaType);

    return SharedDataAddResult.added;
  }

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi) async {
    if (mediaType.isImage) {
      await editorApi.insertImageFile(
        file,
        mediaType.sub.mediaType.toString(),
      );

      return SharedDataAddResult.added;
    }

    return SharedDataAddResult.notAdded;
  }
}

/// Shared data item for a binary
class SharedBinary extends SharedData {
  /// Creates a new [SharedBinary]
  SharedBinary(this.data, this.filename, MediaType mediaType)
      : super(mediaType);

  /// The binary data
  final Uint8List? data;

  /// The optional filename
  final String? filename;

  @override
  Future<SharedDataAddResult> addToMessageBuilder(
    MessageBuilder builder,
  ) async {
    final data = this.data;
    if (data == null) {
      return SharedDataAddResult.notAdded;
    }
    builder.addBinary(data, mediaType, filename: filename);

    return SharedDataAddResult.added;
  }

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi) async {
    final data = this.data;
    if (data != null && mediaType.isImage) {
      await editorApi.insertImageData(
        data,
        mediaType.sub.mediaType.toString(),
      );

      return SharedDataAddResult.added;
    }

    return SharedDataAddResult.notAdded;
  }
}

/// Shared data item for a text
class SharedText extends SharedData {
  /// Creates a new [SharedText]
  SharedText(
    this.text,
    MediaType? mediaType, {
    this.subject,
  }) : super(mediaType ?? MediaType.textPlain);

  /// The text
  final String text;

  /// The optional subject
  final String? subject;

  @override
  Future<SharedDataAddResult> addToMessageBuilder(MessageBuilder builder) {
    builder.text = text;
    if (subject != null) {
      builder.subject = subject;
    }

    return Future.value(SharedDataAddResult.added);
  }

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi) async {
    await editorApi.insertText(text);

    return Future.value(SharedDataAddResult.added);
  }
}

/// Shared data item for a mailto link
class SharedMailto extends SharedData {
  /// Creates a new [SharedMailto]
  SharedMailto(this.mailto)
      : super(MediaType.fromSubtype(MediaSubtype.textHtml));

  /// The mailto link
  final Uri mailto;

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi) {
    // TODO(RV): implement addToEditor
    throw UnimplementedError();
  }

  @override
  Future<SharedDataAddResult> addToMessageBuilder(MessageBuilder builder) {
    // TODO(RV): implement addToMessageBuilder
    throw UnimplementedError();
  }
}
