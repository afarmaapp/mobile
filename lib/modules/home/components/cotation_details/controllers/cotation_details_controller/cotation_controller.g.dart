// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotation_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CotationController on _CotationControllerBase, Store {
  final _$opacityAtom = Atom(name: '_CotationControllerBase.opacity');

  @override
  double get opacity {
    _$opacityAtom.reportRead();
    return super.opacity;
  }

  @override
  set opacity(double value) {
    _$opacityAtom.reportWrite(value, super.opacity, () {
      super.opacity = value;
    });
  }

  final _$heightAtom = Atom(name: '_CotationControllerBase.height');

  @override
  double get height {
    _$heightAtom.reportRead();
    return super.height;
  }

  @override
  set height(double value) {
    _$heightAtom.reportWrite(value, super.height, () {
      super.height = value;
    });
  }

  final _$cotationStateAtom =
      Atom(name: '_CotationControllerBase.cotationState');

  @override
  CotationState get cotationState {
    _$cotationStateAtom.reportRead();
    return super.cotationState;
  }

  @override
  set cotationState(CotationState value) {
    _$cotationStateAtom.reportWrite(value, super.cotationState, () {
      super.cotationState = value;
    });
  }

  final _$selectedProductAtom =
      Atom(name: '_CotationControllerBase.selectedProduct');

  @override
  Product? get selectedProduct {
    _$selectedProductAtom.reportRead();
    return super.selectedProduct;
  }

  @override
  set selectedProduct(Product? value) {
    _$selectedProductAtom.reportWrite(value, super.selectedProduct, () {
      super.selectedProduct = value;
    });
  }

  final _$selectedProductQntAtom =
      Atom(name: '_CotationControllerBase.selectedProductQnt');

  @override
  int get selectedProductQnt {
    _$selectedProductQntAtom.reportRead();
    return super.selectedProductQnt;
  }

  @override
  set selectedProductQnt(int value) {
    _$selectedProductQntAtom.reportWrite(value, super.selectedProductQnt, () {
      super.selectedProductQnt = value;
    });
  }

  final _$cotationsAtom = Atom(name: '_CotationControllerBase.cotations');

  @override
  ObservableList<Cotation> get cotations {
    _$cotationsAtom.reportRead();
    return super.cotations;
  }

  @override
  set cotations(ObservableList<Cotation> value) {
    _$cotationsAtom.reportWrite(value, super.cotations, () {
      super.cotations = value;
    });
  }

  final _$productsAtom = Atom(name: '_CotationControllerBase.products');

  @override
  ObservableList<CartProduct> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<CartProduct> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  final _$durationInMillisecondsAtom =
      Atom(name: '_CotationControllerBase.durationInMilliseconds');

  @override
  int get durationInMilliseconds {
    _$durationInMillisecondsAtom.reportRead();
    return super.durationInMilliseconds;
  }

  @override
  set durationInMilliseconds(int value) {
    _$durationInMillisecondsAtom
        .reportWrite(value, super.durationInMilliseconds, () {
      super.durationInMilliseconds = value;
    });
  }

  final _$changeProductAsyncAction =
      AsyncAction('_CotationControllerBase.changeProduct');

  @override
  Future changeProduct(Product product) {
    return _$changeProductAsyncAction.run(() => super.changeProduct(product));
  }

  final _$toogleShowCotationDetailsAsyncAction =
      AsyncAction('_CotationControllerBase.toogleShowCotationDetails');

  @override
  Future toogleShowCotationDetails(double heightValue, Product? product) {
    return _$toogleShowCotationDetailsAsyncAction
        .run(() => super.toogleShowCotationDetails(heightValue, product));
  }

  final _$goToCotationAsyncAction =
      AsyncAction('_CotationControllerBase.goToCotation');

  @override
  Future goToCotation() {
    return _$goToCotationAsyncAction.run(() => super.goToCotation());
  }

  final _$_CotationControllerBaseActionController =
      ActionController(name: '_CotationControllerBase');

  @override
  dynamic changeQuantity(ChangeQuantity change) {
    final _$actionInfo = _$_CotationControllerBaseActionController.startAction(
        name: '_CotationControllerBase.changeQuantity');
    try {
      return super.changeQuantity(change);
    } finally {
      _$_CotationControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeQuantityInCart(String productId, ChangeQuantity change) {
    final _$actionInfo = _$_CotationControllerBaseActionController.startAction(
        name: '_CotationControllerBase.changeQuantityInCart');
    try {
      return super.changeQuantityInCart(productId, change);
    } finally {
      _$_CotationControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addProduct() {
    final _$actionInfo = _$_CotationControllerBaseActionController.startAction(
        name: '_CotationControllerBase.addProduct');
    try {
      return super.addProduct();
    } finally {
      _$_CotationControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
opacity: ${opacity},
height: ${height},
cotationState: ${cotationState},
selectedProduct: ${selectedProduct},
selectedProductQnt: ${selectedProductQnt},
cotations: ${cotations},
products: ${products},
durationInMilliseconds: ${durationInMilliseconds}
    ''';
  }
}
