class Validator {
  static bool validateEmail(String value) {
    if (value.length < 'a@b.cd'.length) {
      return false;
    }
    final atIndex = value.lastIndexOf('@');
    final dotIndex = value.lastIndexOf('.');
    return (atIndex > 0 && dotIndex > atIndex && dotIndex < value.length - 2);
  }
}
