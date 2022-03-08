class CPFFormatter {
  static String format(String input) {
    if (input == '' || input.length != 11) return '00.000.000-00';
    String ret = '';
    ret += input.substring(0, 3) + '.';
    ret += input.substring(3, 6) + '.';
    ret += input.substring(6, 9) + '-';
    ret += input.substring(9, 11);
    return ret;
  }
}
