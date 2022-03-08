class PolicyOption {
  PolicyOption({required this.name, required this.url, required this.text});

  String name;
  String url;
  String text;

  static List<PolicyOption> defaultList(Map<String, String> urls) {
    return [
      PolicyOption(
          name: 'Política de Privacidade', url: urls['pp'] ?? '', text: ''),
      PolicyOption(name: 'Termos de Uso', url: urls['tou'] ?? '', text: ''),
    ];
  }

  static List<PolicyOption> defaultListFixed() {
    return [
      PolicyOption(
          name: 'aFarma',
          url:
              'https://server.afarma.app.br/afarma-skp-client/about/about-pt_BR.html',
          text: ''),
      PolicyOption(
          name: 'aFarma Popular',
          url:
              'https://server-dev.afarmapopular.com.br/afarma-skp-client/about/about-pt_BR.html',
          text: '')
    ];
  }
}
