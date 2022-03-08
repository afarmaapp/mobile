class CEPFormatter {
  //24220-150

  static String format(String cep) {
    if (cep.length != 8) return '00000-000';
    String ret = '';
    ret += cep.substring(0, 5);
    ret += '-';
    ret += cep.substring(5, 8);
    return ret;
  }
}
