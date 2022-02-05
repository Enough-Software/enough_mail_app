import 'dart:io';
import 'dart:typed_data';

import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail/enough_mail.dart';

enum SharedDataAddState { added, notAdded }

class SharedDataAddResult {
  static const added = SharedDataAddResult(SharedDataAddState.added);
  static const notAdded = SharedDataAddResult(SharedDataAddState.notAdded);
  final SharedDataAddState state;
  final dynamic details;

  const SharedDataAddResult(this.state, [this.details]);
}

abstract class SharedData {
  final MediaType mediaType;

  SharedData(this.mediaType);

  Future<SharedDataAddResult> addToMessageBuilder(MessageBuilder builder);
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi);
}

class SharedFile extends SharedData {
  final File file;
  SharedFile(this.file, MediaType? mediaType)
      : super(mediaType ?? MediaType.guessFromFileName(file.path));

  @override
  Future<SharedDataAddResult> addToMessageBuilder(
      MessageBuilder builder) async {
    await builder.addFile(file, mediaType);
    return SharedDataAddResult.added;
  }

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi? editorApi) async {
    if (mediaType.isImage) {
      await editorApi!
          .insertImageFile(file, mediaType.sub.mediaType.toString());
      return SharedDataAddResult.added;
    }
    return SharedDataAddResult.notAdded;
  }
}

class SharedBinary extends SharedData {
  final Uint8List? data;
  final String? filename;
  SharedBinary(this.data, this.filename, MediaType mediaType)
      : super(mediaType);

  @override
  Future<SharedDataAddResult> addToMessageBuilder(
      MessageBuilder builder) async {
    builder.addBinary(data!, mediaType, filename: filename);
    return SharedDataAddResult.added;
  }

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi) async {
    if (mediaType.isImage) {
      await editorApi.insertImageData(
          data!, mediaType.sub.mediaType.toString());
      return SharedDataAddResult.added;
    }
    return SharedDataAddResult.notAdded;
  }
}

class SharedText extends SharedData {
  final String text;
  final String? subject;
  SharedText(this.text, MediaType? mediaType, {this.subject})
      : super(mediaType ?? MediaType.textPlain);

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

class SharedMailto extends SharedData {
  final Uri mailto;
  SharedMailto(this.mailto)
      : super(MediaType.fromSubtype(MediaSubtype.textHtml));

  @override
  Future<SharedDataAddResult> addToEditor(HtmlEditorApi editorApi) {
    // TODO: implement addToEditor
    throw UnimplementedError();
  }

  @override
  Future<SharedDataAddResult> addToMessageBuilder(MessageBuilder builder) {
    // TODO: implement addToMessageBuilder
    throw UnimplementedError();
  }
}
