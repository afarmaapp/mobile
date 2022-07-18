import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';
import 'package:app/modules/home/models/product/product_model.dart';
import 'package:app/modules/home/repositories/product/product_repository.dart';
import 'package:mobx/mobx.dart';

part 'product_controller.g.dart';

class ProductController = _ProductControllerBase with _$ProductController;

enum ProductState { initial, loading, success, error, empty }

abstract class _ProductControllerBase with Store {
  final c = Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  final repository = ProductRepository();

  @observable
  ObservableList<Product> products = ObservableList.of([]);

  @observable
  String filter = '';

  @observable
  ProductState productsState = ProductState.initial;

  @action
  changeFilter(String value) {
    filter = value;
  }

  @action
  getProducts() async {
    try {
      productsState = ProductState.loading;
      final resp = await repository.getAllProducts(filter);

      if (resp.isNotEmpty) {
        products = ObservableList.of(resp);
        productsState = ProductState.success;
      } else {
        productsState = ProductState.empty;
      }
    } catch (e) {
      print(e);
      productsState = ProductState.error;
      return {
        "error": productsState == ProductState.error,
        "msg": 'Ocorreu um erro inesperado, tente novamente mais tarde!'
      };
    }
  }
}
