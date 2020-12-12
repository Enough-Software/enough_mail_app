class HtmlUtil {
  static String stripConditionals(String html) {
    if (html != null) {
      // this is a very simple mechanism that assumes that
      // the conditional queries are not wrapped but instead
      // sequential.
      final buffer = StringBuffer();
      var includeIndex = 0;
      var startIndex = html.indexOf('<!--[if ');
      while (startIndex != -1) {
        var endIndex = html.indexOf('<![endif]-->', startIndex + 10);
        if (endIndex == -1) {
          print(
              'found start if conditional but not endif conditional in $html');
          return html;
        }
        endIndex += '<![endif]-->'.length;
        final conditionStartIndex = startIndex + '<!--[if '.length;
        final condition = html.substring(
            conditionStartIndex, conditionStartIndex + '!mso '.length);
        if (condition.startsWith('!mso') || condition.startsWith('(!mso')) {
          // ok this code seems to be excluding MS Outlook so we keep it:
          buffer.write(html.substring(includeIndex, endIndex));
        } else {
          // remove this conditional code:
          if (startIndex > includeIndex) {
            buffer.write(html.substring(includeIndex, startIndex));
          }
        }
        startIndex = html.indexOf('<!--[if ', endIndex);
        includeIndex = endIndex;
      }
      if (includeIndex == 0) {
        return html;
      } else {
        buffer.write(html.substring(includeIndex));
        if (false) {
          print('--------------cleaned HTML:---------------------');
          final lines = buffer.toString().split('\r\n');
          for (final line in lines) {
            print(line);
          }
        }
        return buffer.toString();
      }
    }
    return html;
  }
}
