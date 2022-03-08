import 'dart:convert';

import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/PolicyLinks.dart';
import 'package:afarma/model/PolicyOption.dart';
import 'package:afarma/model/Return.dart';

class PolicyOptionRepository {
  static final PolicyOptionRepository _manager =
      PolicyOptionRepository._initializer();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory PolicyOptionRepository() {
    return _manager;
  }

  PolicyOptionRepository._initializer();

  List<PolicyOption> _options = [];
  List<PolicyOption> get options => _options;

  Future<List<PolicyOption>> getOptions() async {
    // Return res = await _connector
    //     .getContent('/api/v1/RegulatoryTerms/allurls/afarma_popular/pt_BR');
    // final parsedRes = jsonDecode(res.returnBody!);
    // _options =
    //     PolicyOption.defaultList(PolicyLinks.fromJSON(parsedRes).toMap());
    _options = PolicyOption.defaultListFixed();

    await Future.forEach(_options, (PolicyOption option) async {
      await loadContent(option);
    });

    return _options;
  }

  Future<PolicyOption> loadContent(PolicyOption option) async {
    // Pega o atexto de cada uma das telas

    Return resBody = await _connector.getContent(option.url);
    if (resBody.responseCode! < 400) {
      String text = resBody.returnBody!
          .replaceAll("\\n", "")
          .replaceAll("\\t", " ")
          .replaceAll("“", "")
          .replaceAll("\"", "")
          .replaceAll("\\", "");
      option.text = text;
    } else {
      option.text = "Ocorreu um erro ao carregar o conteúdo.";
    }

    return option;
  }
}
