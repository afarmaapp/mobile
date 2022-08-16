import 'dart:convert';

import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';
import 'package:app/modules/home/models/product/product_model.dart';

class ProductRepository {
  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  Future<List<Product>> getAllProducts(String filter) async {
    final resp = await _connector.getContent(
        '/api/v1/ProdutoAfarma/produtosAfarmaResearch/${filter.isNotEmpty && filter.length > 4 ? filter : 'dipirona'}');

    if (resp.responseCode! < 400) {
      List respList = resp.returnObject;
      List<Product> products = [];

      for (var json in respList) {
        Map<String, dynamic> jsonParsed = jsonDecode(json["data"]);
        (jsonParsed['valor_concorrente'] as List).removeWhere((obj) =>
            obj['concorrente'] == null || obj['valor_concorrente'] == null);
        (jsonParsed['produto_similar'] as List).removeWhere((obj) =>
            obj['id'] == null ||
            obj['nome'] == null ||
            obj['ean'] == null ||
            obj['valor'] == null);
        products.add(Product.fromJson(jsonParsed));
      }

      return products;
    }

    return resp.returnObject;
  }

  Future<Product> getById(int productId) async {
    final resp =
        await _connector.getContent('/api/v1/ProdutoAfarma/$productId');

    if (resp.responseCode! < 400) {
      Map<String, dynamic> jsonParsed = jsonDecode(resp.returnObject["data"]);

      return Product.fromJson(resp.returnObject);
    }

    return resp.returnObject;
  }
}
