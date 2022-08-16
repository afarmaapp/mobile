import 'dart:convert';

import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';
import 'package:app/modules/cart/models/cotation/cotation_model.dart';
import 'package:app/modules/cart/models/cotation_item/cotation_item_model.dart';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:app/modules/home/models/product/product_model.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

class CartRepository {
  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  final cotationController = GetIt.I.get<CotationController>();

  Future<Product> getCotationInformations(int productId) async {
    final resp =
        await _connector.getContent('/api/v1/ProdutoAfarma/$productId');

    if (resp.responseCode! < 400) {
      Map<String, dynamic> jsonParsed = jsonDecode(resp.returnObject["data"]);

      return Product.fromJson(resp.returnObject);
    }

    return resp.returnObject;
  }

  Future<Map<String, dynamic>> registerCotation() async {
    final resp = await _connector.postContentWithBody(
      '/api/v1/RegistroCotacaoAfarma',
      '{ "nome": "", "data": "${DateTime.now().toIso8601String()}", "email": "" }',
    );

    if (resp.responseCode! < 400) {
      Map<String, dynamic> jsonParsed = jsonDecode(resp.returnBody!);

      final respCode = await makeCotation(jsonParsed['id']);

      if (respCode < 400) {
        return {
          'error': false,
          'msg': 'Cotação feita com Sucesso!',
        };
      } else {
        return {
          'error': true,
          'msg':
              'Ocorreu algum problema ao cotar os produtos, tente novamente mais tarde!\nCódigo de Erro: $respCode',
        };
      }
    } else {
      return {
        'error': true,
        'msg':
            'Ocorreu algum problema ao cotar os produtos, tente novamente mais tarde!',
      };
    }
  }

  Future<int> makeCotation(String cotationId) async {
    for (var i = 0; i < cotationController.products.length; i++) {
      String body =
          '{ "cotacao": {"id": "$cotationId"}, "produto": {"id": "${cotationController.products[i].product.id}"}, "quantidade": ${cotationController.products[i].qnt} }';

      final respCotationProduct = await _connector.postContentWithBody(
        '/api/v1/ItemCotacaoAfarma',
        body,
      );

      if (respCotationProduct.responseCode! >= 400) {
        return respCotationProduct.responseCode!;
      }
    }

    final respCotation = await _connector
        .getContent('/api/v1/RegistroCotacaoAfarma/cotacaoAfarma/$cotationId');

    final respDetailedCotation = await _connector.getContent(
        '/api/v1/RegistroCotacaoAfarma/cotacaoAfarmaDetalhado/$cotationId');

    if (respCotation.responseCode! < 400 &&
        respDetailedCotation.responseCode! < 400) {
      Map<String, dynamic> cotationParsed =
          jsonDecode(respCotation.returnObject[0]["data"]);
      List<Map<String, dynamic>> detailedCotation = [];

      Cotation afarma = Cotation(
        id: cotationId,
        itens: [],
        loja: 'AFARMA',
        total: double.parse(cotationParsed['total'].toString()),
      );

      List<Cotation> concorrentes = (cotationParsed['total_concorrente']
              as List)
          .map((e) => e = Cotation(
              id: cotationId,
              itens: [],
              loja: e['concorrente'],
              total: double.parse(e['total_concorrente'].toStringAsFixed(2))))
          .toList();

      for (var i = 0; i < respDetailedCotation.returnObject.length; i++) {
        Map<String, dynamic> parsed =
            jsonDecode(respDetailedCotation.returnObject[i]['data']);

        afarma.itens.add(
          CotationItem(
            id: parsed['cotacao_id'],
            nome: parsed['nome'],
            quantidade: parsed['quantidade'],
            valor: double.parse(parsed['valor'].toString()),
            total: double.parse(parsed['total'].toString()),
          ),
        );

        if (parsed['detalhamento_concorrente'].length > 0) {
          for (var i = 0; i < parsed['detalhamento_concorrente'].length; i++) {
            concorrentes
                .firstWhere((obj) =>
                    obj.loja ==
                    parsed['detalhamento_concorrente'][i]['concorrente'])
                .itens
                .add(
                  CotationItem(
                    id: parsed['cotacao_id'],
                    nome: parsed['nome'],
                    quantidade: parsed['quantidade'],
                    valor: double.parse(parsed['detalhamento_concorrente'][i]
                            ['valor_concorrente']
                        .toString()),
                    total: double.parse(parsed['detalhamento_concorrente'][i]
                            ['total_concorrente']
                        .toString()),
                  ),
                );
          }
        }
      }
      cotationController.cotations = ObservableList.of([]);

      cotationController.cotations.add(afarma);
      if (cotationParsed['total_concorrente'].length > 0) {
        for (var i = 0; i < cotationParsed['total_concorrente'].length; i++) {
          cotationController.cotations.add(concorrentes.firstWhere((obj) =>
              obj.loja ==
              cotationParsed['total_concorrente'][i]['concorrente']));
        }
      }

      return 200;
    } else {
      if (respCotation.responseCode! >= 400) {
        return respCotation.responseCode!;
      } else {
        return respDetailedCotation.responseCode!;
      }
    }
  }
}
