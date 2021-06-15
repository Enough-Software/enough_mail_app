import 'dart:convert';
import 'package:crypto/crypto.dart';

enum GravatarImage {
  nf, // 404
  mp, // mystery person
  identicon,
  monsterid,
  wavatar,
  retro,
  robohash,
  blank,
}

enum GravatarRating {
  g,
  pg,
  r,
  x,
}

class Gravatar {
  static String imageUrl(
    String email, {
    int? size,
    GravatarImage? defaultImage,
    bool forceDefault = false,
    bool fileExtension = false,
    GravatarRating? rating,
  }) {
    var hashDigest = _generateHash(email);
    final query = <String, String>{};

    if (size != null) query['s'] = size.toString();
    if (defaultImage != null) query['d'] = _imageString(defaultImage);
    if (forceDefault) query['f'] = 'y';
    if (rating != null) query['r'] = _ratingString(rating);
    if (fileExtension) hashDigest += '.png';

    return Uri.https('www.gravatar.com', '/avatar/$hashDigest',
            query.isEmpty ? null : query)
        .toString();
  }

  static String _generateHash(String email) {
    final preparedEmail = email.trim().toLowerCase();
    return md5.convert(utf8.encode(preparedEmail)).toString();
  }

  static String jsonUrl(String email) {
    final hash = _generateHash(email);

    return Uri.https('www.gravatar.com', '/$hash.json').toString();
  }

  static String qrUrl(String email) {
    final hash = _generateHash(email);

    return Uri.https('www.gravatar.com', '/$hash.qr').toString();
  }

  static String _imageString(GravatarImage value) {
    switch (value) {
      case GravatarImage.nf:
        return '404';
      case GravatarImage.mp:
        return 'mp';
      case GravatarImage.identicon:
        return 'identicon';
      case GravatarImage.monsterid:
        return 'monsterid';
      case GravatarImage.wavatar:
        return 'wavatar';
      case GravatarImage.retro:
        return 'retro';
      case GravatarImage.robohash:
        return 'robohash';
      case GravatarImage.blank:
        return 'blank';
    }
  }

  static String _ratingString(GravatarRating value) {
    switch (value) {
      case GravatarRating.g:
        return 'g';
      case GravatarRating.pg:
        return 'pg';
      case GravatarRating.r:
        return 'r';
      case GravatarRating.x:
        return 'x';
    }
  }
}
