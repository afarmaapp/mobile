import 'dart:convert';

import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';
import 'package:app/modules/login/helper/register_details.dart';
import 'package:app/shared/login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobx/mobx.dart';

part 'login_controller.g.dart';

class LoginController = _LoginControllerBase with _$LoginController;

enum GoogleAuthState { initial, loading, success, error }
enum AuthState { initial, loading, success, error }
enum Logged { initial, logged, notLogged }
enum RegisterState { initial, loading, success, error }

abstract class _LoginControllerBase with Store {
  final c = Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  @observable
  Login inputs = Login();

  @observable
  GoogleAuthState googleAuthState = GoogleAuthState.initial;

  @observable
  Logged logged = Logged.initial;

  @observable
  bool localLogin = false;

  @observable
  bool showErrors = false;

  @observable
  AuthState authState = AuthState.initial;

  @observable
  RegisterState registerState = RegisterState.initial;

  @observable
  String photoUrlGoogle = '';

  @action
  changeEmail(String value) {
    inputs.login = value;
  }

  @action
  toogleShowErrors() {
    showErrors = !showErrors;
  }

  @action
  toogleLocalLogin() {
    localLogin = !localLogin;
  }

  @action
  changePassword(String value) {
    inputs.password = value;
  }

  @action
  loginWithEmailAndPassword() async {
    try {
      authState = AuthState.loading;
      final resp = await c.loginWithParams(inputs);

      if (resp.responseCode! < 400) {
        authState = AuthState.success;
        logged = Logged.logged;
        return {
          "error": authState == AuthState.error,
          "msg": "Login Realizado com Sucesso"
        };
      } else {
        List parsedResp = jsonDecode(resp.returnBody!);
        authState = AuthState.error;
        return {
          "error": authState == AuthState.error,
          "msg": parsedResp[0]["error"]
        };
      }
    } catch (e) {
      print(e);
      authState = AuthState.error;
      return {
        "error": authState == AuthState.error,
        "msg": 'Ocorreu um erro inesperado, tente novamente mais tarde!'
      };
    }
  }

  @action
  signUp(RegisterDetails registerDetails) async {
    try {
      final respListUsers = await c.getContent('/api/v1/Usuario/list');

      if (respListUsers.responseCode! < 400) {
        List users = jsonDecode(respListUsers.returnBody!);
        int indexIfExists = users
            .indexWhere((element) => element["email"] == registerDetails.email);

        if (indexIfExists == -1) {
          String bodyPersist =
              '{ "nome": "${registerDetails.nome}", "email": "${registerDetails.email}", "telefone": "${registerDetails.telefone!.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '')}", "cpf": "${registerDetails.cpf!.replaceAll('-', '').replaceAll('.', '')}", "perfil": { "id": 2, "nome": "local" } }';
          final resPersist = await c.postContentWithBody(
              '/api/v1/Usuario/persist', bodyPersist);

          if (resPersist.responseCode! < 400) {
            Map<String, dynamic> jsonParsed =
                jsonDecode(resPersist.returnBody!);
            String bodyCreatePass =
                '{ "email": "${registerDetails.email}", "novaSenha": "${registerDetails.password}", "codigoCadastroSenha": "${jsonParsed["codigoCadastroSenha"]}" }';

            final resCreatePass = await c.postContentWithBody(
                '/api/v1/autenticacao/senha/criar', bodyCreatePass);

            if (resCreatePass.responseCode! < 400) {
              final respAuth = await c.loginWithParams(Login(
                  login: registerDetails.email,
                  password: registerDetails.password));

              if (respAuth.responseCode! < 400) {
                registerState = RegisterState.success;

                return {"error": false, "msg": "Login Realizado com Sucesso"};
              } else {
                registerState = RegisterState.error;

                return {
                  "error": registerState == RegisterState.error,
                  "msg": respAuth.returnObject[0]["error"]
                };
              }
            } else {
              registerState = RegisterState.error;

              return {
                "error": registerState == RegisterState.error,
                "msg": resCreatePass.returnObject[0]["error"]
              };
            }
          } else {
            registerState = RegisterState.error;

            return {
              "error": registerState == RegisterState.error,
              "msg": resPersist.returnObject[0]["error"]
            };
          }
        } else {
          return {
            "error": googleAuthState == GoogleAuthState.error,
            "msg": "Já existe uma conta com esse E-mail."
          };
        }
      }
    } catch (e) {
      print(e);
      googleAuthState = GoogleAuthState.error;
      return {
        "error": googleAuthState == GoogleAuthState.error,
        "msg": 'Ocorreu um erro inesperado, tente novamente mais tarde!',
      };
    }
  }

  @action
  googleSignIn() async {
    try {
      googleAuthState = GoogleAuthState.loading;
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );

      final account = await _googleSignIn.signIn();
      photoUrlGoogle = account!.photoUrl!;

      final respListUsers = await c.getContent('/api/v1/Usuario/list');

      if (respListUsers.responseCode! < 400) {
        List users = jsonDecode(respListUsers.returnBody!);
        int indexIfExists =
            users.indexWhere((element) => element["email"] == account.email);

        if (indexIfExists == -1) {
          String bodyPersist =
              '{ "nome": "${account.displayName}", "email": "${account.email}", "perfil": { "id": 2, "nome": "google" } }';
          final resPersist = await c.postContentWithBody(
              '/api/v1/Usuario/persist', bodyPersist);

          if (resPersist.responseCode! < 400) {
            Map<String, dynamic> jsonParsed =
                jsonDecode(resPersist.returnBody!);
            String bodyCreatePass =
                '{ "email": "${account.email}", "novaSenha": "${account.id}", "codigoCadastroSenha": "${jsonParsed["codigoCadastroSenha"]}" }';

            final resCreatePass = await c.postContentWithBody(
                '/api/v1/autenticacao/senha/criar', bodyCreatePass);

            if (resCreatePass.responseCode! < 400) {
              final respAuth = await c.loginWithParams(
                  Login(login: account.email, password: account.id));

              if (respAuth.responseCode! < 400) {
                googleAuthState = GoogleAuthState.success;

                return {"error": false, "msg": "Login Realizado com Sucesso"};
              } else {
                googleAuthState = GoogleAuthState.error;

                return {
                  "error": googleAuthState == GoogleAuthState.error,
                  "msg": respAuth.returnObject[0]["error"]
                };
              }
            }
          }
        } else {
          final respAuth = await c.loginWithParams(
              Login(login: account.email, password: account.id));

          if (respAuth.responseCode! < 400) {
            googleAuthState = GoogleAuthState.success;

            return {"error": false, "msg": "Login Realizado com Sucesso"};
          } else {
            googleAuthState = GoogleAuthState.error;

            return {
              "error": googleAuthState == GoogleAuthState.error,
              "msg": respAuth.returnObject[0]["error"]
            };
          }
        }
      }
    } catch (e) {
      print(e);
      googleAuthState = GoogleAuthState.error;
      return {
        "error": googleAuthState == GoogleAuthState.error,
        "msg": 'Ocorreu um erro inesperado, tente novamente mais tarde!',
      };
    }
  }
}
