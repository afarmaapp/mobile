class PhoneFormatter {
  static String format(String? number) {
    if (number != null && number.contains('(')) return number; // já formatado
    if (number == null || number.length < 10) return '(00) 00000-0000';
    int length = number.length;
    String ret = '';
    ret += '(${number.substring(0, 2)})'; // (xx)
    ret += ' ${number.substring(2, (length == 10) ? 6 : 7)}'; // xxxx
    ret += '-${number.substring((length == 10) ? 6 : 7, length)}'; // -xxxx
    return ret;
  }
}
