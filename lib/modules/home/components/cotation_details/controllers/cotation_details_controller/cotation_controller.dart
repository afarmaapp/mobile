import 'package:app/modules/cart/models/cart/cart_product_model.dart';
import 'package:app/modules/cart/models/cotation/cotation_model.dart';
import 'package:app/modules/cart/repositories/cart/cart_repository.dart';
import 'package:app/modules/home/models/product/product_model.dart';
import 'package:mobx/mobx.dart';

part 'cotation_controller.g.dart';

class CotationController = _CotationControllerBase with _$CotationController;

enum ChangeQuantity { add, remove }

enum CotationState { initial, loading, success, error }

abstract class _CotationControllerBase with Store {
  @observable
  double opacity = 0;

  @observable
  double? height = 0;

  @observable
  CotationState cotationState = CotationState.initial;

  @observable
  Product? selectedProduct;

  @observable
  int selectedProductQnt = 1;

  @action
  changeQuantity(ChangeQuantity change) {
    if (change == ChangeQuantity.add) {
      selectedProductQnt = selectedProductQnt + 1;
    } else if (selectedProductQnt > 1) {
      selectedProductQnt = selectedProductQnt - 1;
    }
  }

  @observable
  ObservableList<Cotation> cotations = ObservableList.of([]);

  @observable
  ObservableList<CartProduct> products = ObservableList.of([]);

  @action
  changeQuantityInCart(String productId, ChangeQuantity change) {
    int index =
        products.indexWhere((element) => element.product.id == productId);

    if (change == ChangeQuantity.add) {
      products[index] = CartProduct(
          product: products[index].product, qnt: products[index].qnt + 1);
    } else {
      if (products[index].qnt > 1) {
        products[index] = CartProduct(
            product: products[index].product, qnt: products[index].qnt - 1);
      } else {
        products.removeWhere((element) => element.product.id == productId);
      }
    }
  }

  @observable
  int durationInMilliseconds = 400;

  @action
  addProduct() {
    int indexIfExist = products
        .indexWhere((element) => element.product.id == selectedProduct!.id);

    if (indexIfExist == -1) {
      products
          .add(CartProduct(product: selectedProduct!, qnt: selectedProductQnt));
    } else {
      products[indexIfExist] = CartProduct(
          product: products[indexIfExist].product,
          qnt: products[indexIfExist].qnt + selectedProductQnt);
    }

    toogleShowCotationDetails(0, null);
  }

  @action
  changeProduct(Product product) async {
    opacity = 0;
    await Future.delayed(const Duration(milliseconds: 400));
    selectedProduct = product;
    selectedProductQnt = 1;
    opacity = 1;
  }

  @action
  toogleShowCotationDetails(double heightValue, Product? product) async {
    if (opacity == 0) {
      selectedProduct = product;
      height = null;
      await Future.delayed(const Duration(milliseconds: 400));
      selectedProductQnt = 1;
      opacity = 1;
    } else {
      opacity = 0;
      await Future.delayed(const Duration(milliseconds: 400));
      selectedProductQnt = 1;
      selectedProduct = null;
      height = 0;
    }
  }

  @action
  goToCotation() async {
    CartRepository cartRepository = CartRepository();

    try {
      cotationState = CotationState.loading;
      Map<String, dynamic> resp = await cartRepository.registerCotation();

      if (!resp["error"]) {
        cotationState = CotationState.success;
        return resp;
      } else {
        cotationState = CotationState.error;
        return resp;
      }
    } catch (e) {
      print(e);
      cotationState = CotationState.error;
      return {
        "error": cotationState == CotationState.error,
        "msg": 'Ocorreu um erro inesperado, tente novamente mais tarde!'
      };
    }
  }
}
