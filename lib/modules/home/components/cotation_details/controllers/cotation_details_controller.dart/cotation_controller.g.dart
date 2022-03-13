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

  final _$toogleShowCotationDetailsAsyncAction =
      AsyncAction('_CotationControllerBase.toogleShowCotationDetails');

  @override
  Future toogleShowCotationDetails(double heightValue) {
    return _$toogleShowCotationDetailsAsyncAction
        .run(() => super.toogleShowCotationDetails(heightValue));
  }

  @override
  String toString() {
    return '''
opacity: ${opacity},
height: ${height},
durationInMilliseconds: ${durationInMilliseconds}
    ''';
  }
}
