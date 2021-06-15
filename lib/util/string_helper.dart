import 'dart:math';

class StringHelper {
  StringHelper._();
  static String? largestCommonSequence(List<String> texts) {
    if (texts.isEmpty) {
      return null;
    }
    String? text = texts.first;
    if (texts.length == 1) {
      return text;
    }
    for (var i = 1; i < texts.length; i++) {
      text = largestCommonSequenceOf(text!, texts[i]);
      if (text == null) {
        return null;
      }
    }
    return text;
  }

  static String? largestCommonSequenceOf(String first, String second) {
    // print('lcs of "$first" and "$second"');
    // problem: the longest sequence between first and second is not necessarily the longest sequence between all
    String shorter, longer;
    if (first.length <= second.length) {
      shorter = first;
      longer = second;
    } else {
      shorter = second;
      longer = first;
    }
    if (longer.contains(shorter)) {
      return shorter;
    }
    final shorterRunes = shorter.runes.toList();
    final longerRunes = longer.runes.toList();
    final matches = <_StringSequence>[];
    var longestLengthSoFar = 0;
    for (var sri = 0; sri < shorterRunes.length; sri++) {
      final shortRune = shorterRunes[sri];
      for (var lri = 0; lri < longerRunes.length; lri++) {
        final longRune = longerRunes[lri];
        if (shortRune == longRune) {
          final maxIndex =
              min(shorterRunes.length - sri, longerRunes.length - lri);
          var length = 1;
          if (length + maxIndex > longestLengthSoFar) {
            // print('sri: $sri lri: $lri, min: $maxIndex');
            for (var i = 1; i < maxIndex; i++) {
              if (longerRunes[lri + i] != shorterRunes[sri + i]) {
                break;
              }
              length++;
            }
            if (length > longestLengthSoFar) {
              longestLengthSoFar = length;
              // print('add from $sri with length $length');
              matches.add(_StringSequence(sri, length));
            }
          }
        }
      }
    }
    if (matches.isEmpty) {
      return null;
    }
    var longest = matches.first;
    for (var i = 1; i < matches.length; i++) {
      final sequence = matches[i];
      if (sequence.length > longest.length) {
        longest = sequence;
      }
    }
    return String.fromCharCodes(
        shorterRunes, longest.startIndex, longest.startIndex + longest.length);
  }
}

class _StringSequence {
  final int startIndex;
  final int length;

  _StringSequence(this.startIndex, this.length);
}
