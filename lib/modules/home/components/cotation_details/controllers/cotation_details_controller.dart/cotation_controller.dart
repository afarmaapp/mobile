import 'package:mobx/mobx.dart';

part 'cotation_controller.g.dart';

class CotationController = _CotationControllerBase with _$CotationController;

enum GoogleAuthState { initial, loading, success, error }

abstract class _CotationControllerBase with Store {
  @observable
  double opacity = 0;

  @observable
  double height = 0;

  @observable
  int durationInMilliseconds = 400;

  @action
  toogleShowCotationDetails(double heightValue) async {
    if (opacity == 0) {
      height = heightValue;
      await Future.delayed(const Duration(milliseconds: 400));
      opacity = 1;
    } else {
      opacity = 0;
      await Future.delayed(const Duration(milliseconds: 400));
      height = 0;
    }
  }
}
