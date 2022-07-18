// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotation_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CotationController on _CotationControllerBase, Store {
  late final _$opacityAtom =
      Atom(name: '_CotationControllerBase.opacity', context: context);

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

  late final _$heightAtom =
      Atom(name: '_CotationControllerBase.height', context: context);

  @override
  double? get height {
    _$heightAtom.reportRead();
    return super.height;
  }

  @override
  set height(double? value) {
    _$heightAtom.reportWrite(value, super.height, () {
      super.height = value;
    });
  }

  late final _$cotationStateAtom =
      Atom(name: '_CotationControllerBase.cotationState', context: context);

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

  late final _$selectedProductAtom =
      Atom(name: '_CotationControllerBase.selectedProduct', context: context);

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

  late final _$selectedProductQntAtom = Atom(
      name: '_CotationControllerBase.selectedProductQnt', context: context);

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

  late final _$cotationsAtom =
      Atom(name: '_CotationControllerBase.cotations', context: context);

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

  late final _$productsAtom =
      Atom(name: '_CotationControllerBase.products', context: context);

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

  late final _$durationInMillisecondsAtom = Atom(
      name: '_CotationControllerBase.durationInMilliseconds', context: context);

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

  late final _$changeProductAsyncAction =
      AsyncAction('_CotationControllerBase.changeProduct', context: context);

  @override
  Future changeProduct(Product product) {
    return _$changeProductAsyncAction.run(() => super.changeProduct(product));
  }

  late final _$toogleShowCotationDetailsAsyncAction = AsyncAction(
      '_CotationControllerBase.toogleShowCotationDetails',
      context: context);

  @override
  Future toogleShowCotationDetails(double heightValue, Product? product) {
    return _$toogleShowCotationDetailsAsyncAction
        .run(() => super.toogleShowCotationDetails(heightValue, product));
  }

  late final _$goToCotationAsyncAction =
      AsyncAction('_CotationControllerBase.goToCotation', context: context);

  @override
  Future goToCotation() {
    return _$goToCotationAsyncAction.run(() => super.goToCotation());
  }

  late final _$_CotationControllerBaseActionController =
      ActionController(name: '_CotationControllerBase', context: context);

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
