// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoginController on _LoginControllerBase, Store {
  late final _$inputsAtom =
      Atom(name: '_LoginControllerBase.inputs', context: context);

  @override
  Login get inputs {
    _$inputsAtom.reportRead();
    return super.inputs;
  }

  @override
  set inputs(Login value) {
    _$inputsAtom.reportWrite(value, super.inputs, () {
      super.inputs = value;
    });
  }

  late final _$googleAuthStateAtom =
      Atom(name: '_LoginControllerBase.googleAuthState', context: context);

  @override
  GoogleAuthState get googleAuthState {
    _$googleAuthStateAtom.reportRead();
    return super.googleAuthState;
  }

  @override
  set googleAuthState(GoogleAuthState value) {
    _$googleAuthStateAtom.reportWrite(value, super.googleAuthState, () {
      super.googleAuthState = value;
    });
  }

  late final _$loggedAtom =
      Atom(name: '_LoginControllerBase.logged', context: context);

  @override
  Logged get logged {
    _$loggedAtom.reportRead();
    return super.logged;
  }

  @override
  set logged(Logged value) {
    _$loggedAtom.reportWrite(value, super.logged, () {
      super.logged = value;
    });
  }

  late final _$localLoginAtom =
      Atom(name: '_LoginControllerBase.localLogin', context: context);

  @override
  bool get localLogin {
    _$localLoginAtom.reportRead();
    return super.localLogin;
  }

  @override
  set localLogin(bool value) {
    _$localLoginAtom.reportWrite(value, super.localLogin, () {
      super.localLogin = value;
    });
  }

  late final _$showErrorsAtom =
      Atom(name: '_LoginControllerBase.showErrors', context: context);

  @override
  bool get showErrors {
    _$showErrorsAtom.reportRead();
    return super.showErrors;
  }

  @override
  set showErrors(bool value) {
    _$showErrorsAtom.reportWrite(value, super.showErrors, () {
      super.showErrors = value;
    });
  }

  late final _$authStateAtom =
      Atom(name: '_LoginControllerBase.authState', context: context);

  @override
  AuthState get authState {
    _$authStateAtom.reportRead();
    return super.authState;
  }

  @override
  set authState(AuthState value) {
    _$authStateAtom.reportWrite(value, super.authState, () {
      super.authState = value;
    });
  }

  late final _$registerStateAtom =
      Atom(name: '_LoginControllerBase.registerState', context: context);

  @override
  RegisterState get registerState {
    _$registerStateAtom.reportRead();
    return super.registerState;
  }

  @override
  set registerState(RegisterState value) {
    _$registerStateAtom.reportWrite(value, super.registerState, () {
      super.registerState = value;
    });
  }

  late final _$photoUrlGoogleAtom =
      Atom(name: '_LoginControllerBase.photoUrlGoogle', context: context);

  @override
  String get photoUrlGoogle {
    _$photoUrlGoogleAtom.reportRead();
    return super.photoUrlGoogle;
  }

  @override
  set photoUrlGoogle(String value) {
    _$photoUrlGoogleAtom.reportWrite(value, super.photoUrlGoogle, () {
      super.photoUrlGoogle = value;
    });
  }

  late final _$loginWithEmailAndPasswordAsyncAction = AsyncAction(
      '_LoginControllerBase.loginWithEmailAndPassword',
      context: context);

  @override
  Future loginWithEmailAndPassword() {
    return _$loginWithEmailAndPasswordAsyncAction
        .run(() => super.loginWithEmailAndPassword());
  }

  late final _$signUpAsyncAction =
      AsyncAction('_LoginControllerBase.signUp', context: context);

  @override
  Future signUp(RegisterDetails registerDetails) {
    return _$signUpAsyncAction.run(() => super.signUp(registerDetails));
  }

  late final _$googleSignInAsyncAction =
      AsyncAction('_LoginControllerBase.googleSignIn', context: context);

  @override
  Future googleSignIn() {
    return _$googleSignInAsyncAction.run(() => super.googleSignIn());
  }

  late final _$_LoginControllerBaseActionController =
      ActionController(name: '_LoginControllerBase', context: context);

  @override
  dynamic changeEmail(String value) {
    final _$actionInfo = _$_LoginControllerBaseActionController.startAction(
        name: '_LoginControllerBase.changeEmail');
    try {
      return super.changeEmail(value);
    } finally {
      _$_LoginControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic toogleShowErrors() {
    final _$actionInfo = _$_LoginControllerBaseActionController.startAction(
        name: '_LoginControllerBase.toogleShowErrors');
    try {
      return super.toogleShowErrors();
    } finally {
      _$_LoginControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic toogleLocalLogin() {
    final _$actionInfo = _$_LoginControllerBaseActionController.startAction(
        name: '_LoginControllerBase.toogleLocalLogin');
    try {
      return super.toogleLocalLogin();
    } finally {
      _$_LoginControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changePassword(String value) {
    final _$actionInfo = _$_LoginControllerBaseActionController.startAction(
        name: '_LoginControllerBase.changePassword');
    try {
      return super.changePassword(value);
    } finally {
      _$_LoginControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
inputs: ${inputs},
googleAuthState: ${googleAuthState},
logged: ${logged},
localLogin: ${localLogin},
showErrors: ${showErrors},
authState: ${authState},
registerState: ${registerState},
photoUrlGoogle: ${photoUrlGoogle}
    ''';
  }
}
