// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductController on _ProductControllerBase, Store {
  late final _$productsAtom =
      Atom(name: '_ProductControllerBase.products', context: context);

  @override
  ObservableList<Product> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<Product> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$filterAtom =
      Atom(name: '_ProductControllerBase.filter', context: context);

  @override
  String get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(String value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$productsStateAtom =
      Atom(name: '_ProductControllerBase.productsState', context: context);

  @override
  ProductState get productsState {
    _$productsStateAtom.reportRead();
    return super.productsState;
  }

  @override
  set productsState(ProductState value) {
    _$productsStateAtom.reportWrite(value, super.productsState, () {
      super.productsState = value;
    });
  }

  late final _$getProductsAsyncAction =
      AsyncAction('_ProductControllerBase.getProducts', context: context);

  @override
  Future getProducts() {
    return _$getProductsAsyncAction.run(() => super.getProducts());
  }

  late final _$_ProductControllerBaseActionController =
      ActionController(name: '_ProductControllerBase', context: context);

  @override
  dynamic changeFilter(String value) {
    final _$actionInfo = _$_ProductControllerBaseActionController.startAction(
        name: '_ProductControllerBase.changeFilter');
    try {
      return super.changeFilter(value);
    } finally {
      _$_ProductControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
products: ${products},
filter: ${filter},
productsState: ${productsState}
    ''';
  }
}
