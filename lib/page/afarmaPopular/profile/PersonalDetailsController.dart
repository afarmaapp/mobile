import 'dart:convert';

// import 'package:afarma/AboutUsController.dart';
import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/helper/popularHelpers/CurrentDeviceInfo.dart';
import 'package:afarma/page/afarmaPopular/ViewImageWidget.dart';
import 'package:afarma/page/afarmaPopular/profile/LoginController.dart';
import 'package:afarma/service/DocumentScanner.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';

class PersonalDetails {
  String? name;
  String? cpf;
  String? rg;
  String? phone;
  String? email;
  String? password;
  File? idImage;

  File? idFront;
  File? idBack;

  bool? acceptedTerms = false;

  // String toJSON() {
  //   return '{ "nome": "$name", "cpf": "${cpf.trim()}", "email": "${email.trim()}", "telefone": "${phone.trim()}", "perfil": { "id": 2 } }';
  // }

  Future<String> toJSONWithToken() async {
    final deviceToken = await Connector.getDeviceToken();

    print('DeviceToken JSON with Token === $deviceToken');

    return '{ "nome": "$name", "cpf": "${cpf!.trim()}", "email": "${email!.trim()}", "telefone": "${phone!.trim()}", "deviceToken": "$deviceToken", "perfil": { "id": 2 } }';
  }

  void populateFromUser(User usr) {
    name = usr.name;
    cpf = usr.cpf;
    phone = usr.cellphone;
    email = usr.email;
  }

  bool canConfirm() {
    return name != null &&
        name!.trim().length > 0 &&
        cpf != null &&
        cpf!.trim().length == 11 &&
        rg != null &&
        rg!.trim().length > 0 &&
        phone != null &&
        phone!.trim().length > 0 &&
        email != null &&
        email!.contains('@') &&
        password != null &&
        (idFront != null || idBack != null);
  }
}

class PersonalDetailsController extends StatefulWidget {
  PersonalDetailsController({this.isFromPurchase = false});

  final bool isFromPurchase;

  @override
  _PersonalDetailsControllerState createState() =>
      _PersonalDetailsControllerState();
}

class _PersonalDetailsControllerState extends State<PersonalDetailsController> {
  Connector _connector = Connector(
      baseURL: DefaultURL.apiURLFromEnv(Environment.prod),
      baseURI: DefaultURI.afarma);
  MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  PersonalDetails _personalDetails = PersonalDetails();

  KeyboardUtils _keyboardUtils = KeyboardUtils();
  double bottomPadding = 0.0;
  bool? shouldFix;

  @override
  void initState() {
    super.initState();
    shouldFixFlutter();
    _keyboardUtils.add(
        listener: KeyboardListener(
            willHideKeyboard: handleHideKeyboard,
            willShowKeyboard: (kHeight) => handleShowKeyboard(kHeight)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: Text(
          'Dados Pessoais',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: _mainBody(),
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(bottom: bottomPadding),
      ),
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            child: Column(
              children: [
                SizedBox(height: 20.0),
                _textField('Nome Completo', [], TextInputType.name, (val) {
                  _personalDetails.name = val;
                }, null),
                _textField('CPF', [_cpfFormatter], TextInputType.number, (val) {
                  _personalDetails.cpf = _cpfFormatter.getUnmaskedText();
                }, null),
                _textField('Identidade', [], TextInputType.number, (val) {
                  _personalDetails.rg = val;
                }, null),
                _textField('Celular', [_phoneFormatter], TextInputType.number,
                    (val) {
                  _personalDetails.phone = _phoneFormatter.getUnmaskedText();
                },
                    Text(
                      'Insira um número com DDD e 9 dígitos',
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    )),
                _textField('Email', [], TextInputType.emailAddress, (val) {
                  _personalDetails.email = val;
                }, null),
                _textField('Senha', [], TextInputType.text, (val) {
                  _personalDetails.password = val;
                }, null),
                _idWidget(),
                _termsWidget()
              ],
            ),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
          ),
          SizedBox(height: 20.0),
          ButtonTheme(
            child: RaisedButton(
              child: Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              color: Color.fromRGBO(0, 169, 211, 1),
              /* blue */
              onPressed: () => _saveAndQuit(),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            height: 50,
            minWidth: MediaQuery.of(context).size.width - 40,
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _idWidget() {
    return Column(
      children: [
        Row(children: [
          Text('Foto do documento (RG ou CNH)',
              style: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ]),
        SizedBox(height: 20.0),
        Row(
          children: [
            Column(
              children: [
                ButtonTheme(
                    child: RaisedButton(
                        child: Row(children: [
                          Icon(
                            Icons.attach_file,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15.0),
                          Text(
                            'Frente',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                        color: Color.fromRGBO(67, 67, 67, 1),
                        /* dark grey */
                        onPressed: () => _personalDetails.idFront == null
                            ? _addIDPicture(true)
                            : _idImageOptions(_personalDetails.idFront),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                _personalDetails.idFront != null
                    ? InkWell(
                        child: Image(
                            image: FileImage(_personalDetails.idFront!),
                            height: 100,
                            width: 100),
                        onTap: () => _idImageOptions(_personalDetails.idFront),
                      )
                    : Container(
                        height: (_personalDetails.idBack != null ? 100 : 0),
                      ),
              ],
            ),
            Column(
              children: [
                ButtonTheme(
                    child: RaisedButton(
                        child: Row(children: [
                          Icon(
                            Icons.attach_file,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15.0),
                          Text(
                            'Verso',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                        color: Color.fromRGBO(67, 67, 67, 1),
                        /* dark grey */
                        onPressed: () => _personalDetails.idBack == null
                            ? _addIDPicture(false)
                            : _idImageOptions(_personalDetails.idBack),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                _personalDetails.idBack != null
                    ? InkWell(
                        child: Image(
                            image: FileImage(_personalDetails.idBack!),
                            height: 100,
                            width: 100),
                        onTap: () => _idImageOptions(_personalDetails.idBack),
                      )
                    : Container(
                        height: (_personalDetails.idFront != null ? 100 : 0),
                      )
              ],
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
        Divider(
          color: Colors.grey.withOpacity(0.6),
          thickness: 1.0,
        )
      ],
    );
  }

  Widget _termsWidget() {
    return Row(
      children: [
        Checkbox(
          onChanged: (val) {
            _personalDetails.acceptedTerms = val;
            setState(() {});
          },
          value: _personalDetails.acceptedTerms,
        ),
        RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black),
              text: 'Eu li e aceito os ',
              children: [
                TextSpan(
                  style: TextStyle(color: Colors.red),
                  text: 'termos de uso.',
                  recognizer: TapGestureRecognizer()..onTap = () => {},
                )
              ]),
        )
      ],
    );
  }

  Widget _textField(
      String title,
      List<TextInputFormatter> formatters,
      TextInputType keyboardType,
      Function(String) onSubmitted,
      Widget? bottom) {
    final ret = TextField(
      autocorrect: false,
      autofocus: false,
      cursorColor: Color.fromRGBO(255, 49, 49, 1),
      /* red */
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(51, 146, 216, 1),
        focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(255, 49, 49, 1) /* red */)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.6))),
        hintText: title,
        hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 18,
            fontWeight: FontWeight.w600),
      ),
      inputFormatters: formatters,
      enableSuggestions: false,
      expands: false,
      keyboardType: keyboardType,
      maxLines: 1,
      obscureText: (title.toLowerCase() == 'senha'),
      onChanged: onSubmitted,
      onSubmitted: onSubmitted,
      textCapitalization: TextCapitalization.none,
      style: TextStyle(color: Colors.black),
    );
    return Padding(
      child: Column(
        children: [ret, (bottom != null) ? bottom : Container()],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  void _addIDPicture(bool isFront) async {
    File pickedImage;
    // bool isSimulator;
    // if (Platform.isIOS) {
    //   IosDeviceInfo deviceInfo =
    //       CurrentDeviceInfo().deviceInfo as IosDeviceInfo;
    //   isSimulator = !deviceInfo.isPhysicalDevice;
    // } else {
    //   AndroidDeviceInfo deviceInfo =
    //       CurrentDeviceInfo().deviceInfo as AndroidDeviceInfo;
    //   isSimulator = !deviceInfo.isPhysicalDevice;
    // }
    pickedImage = await _getImage('photo', context);
    _addPicture(pickedImage, isFront);
    /*
    showDialog(
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          actions: [
            FlatButton(
              child: Text('Tirar foto'),
              onPressed: () async {
                Navigator.pop(context);
                pickedImage = await _getImage(isSimulator ? ImageSource.gallery : ImageSource.camera);
                _addPicture(pickedImage);
              }
            ),
            FlatButton(
              child: Text('Escolher na galeria'),
              onPressed: () async {
                Navigator.pop(context);
                pickedImage = await _getImage(ImageSource.gallery);
                _addPicture(pickedImage);
              }
            )
          ],
          content: Text('Tirar foto ou escolher na galeria?'),
        );
      },
      context: context
    );
    */
  }

/*
  Future<PickedFile> _getImage(ImageSource src) async {
    //PickedFile image = await ImagePicker().getImage(source: src);
    File image = await DocumentScanner.getDocument(ImageSource.camera);
    return image;
  }
*/
  Future<File> _getImage(String typeScan, context) async {
    //PickedFile image = await ImagePicker().getImage(source: src);
    File image = await DocumentScanner.getDocument(typeScan, context);
    return image;
  }

  void _addPicture(File pickedImage, bool isFront) {
    if (isFront) {
      _personalDetails.idFront = pickedImage;
    } else {
      _personalDetails.idBack = pickedImage;
    }
    if (mounted) setState(() {});
  }

  void _idImageOptions(File? img) async {
    final a = await showModalBottomSheet(
        builder: (context) => Container(
              child: Column(
                children: [
                  GestureDetector(
                    child: Image.file(
                      img!,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    children: [
                      ButtonTheme(
                        child: RaisedButton(
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_circle,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Excluir',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          color: Color.fromRGBO(67, 67, 67, 1),
                          /* dark grey */
                          onPressed: () {
                            if (_personalDetails.idFront == img) {
                              _personalDetails.idFront = null;
                            } else {
                              _personalDetails.idBack = null;
                            }
                            Navigator.pop(context);
                            if (mounted) setState(() {});
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        height: 50,
                      ),
                      SizedBox(height: 20.0),
                      ButtonTheme(
                        child: RaisedButton(
                          child: Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Ver imagem',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          color: Color.fromRGBO(67, 67, 67, 1),
                          /* dark grey */
                          onPressed: () {
                            Navigator.pop(context);
                            Get.to(ViewImageWidget(image: FileImage(img)),
                                fullscreenDialog: true);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        height: 50,
                      ),
                    ].reversed.toList(),
                  ),
                  SizedBox(height: 20.0),
                  FlatButton(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.only(
                  top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
            ),
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
  }

  void _saveAndQuit() async {
    if (!_personalDetails.acceptedTerms!) {
      return _alert('Aceite os termos de uso e tente novamente.', null);
    }
    if (_personalDetails.canConfirm()) {
      return _sendUserDetails();
    } else {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
              content: Text('Preencha todos os campos e tente novamente'),
            );
          },
          context: context);
    }
  }

  // void _sendUserDetails() async {
  //   _loadingAlert('Criando usuário...');
  //   final resp = await _connector.postContentWithBody(
  //       '/api/v1/Usuario/persist', await _personalDetails.toJSONWithToken());
  //   print('DeviceToken: ${_personalDetails.toJSONWithToken()}');
  //   Navigator.pop(context);
  //   if (resp.responseCode < 400) {
  //     Map parsedResp = jsonDecode(resp.returnBody);
  //     String passwordToken = parsedResp['codigoCadastroSenha'] as String;
  //     _registerPassword(passwordToken);
  //   } else if (resp.responseCode == 409) {
  //     _alert('Usuário já cadastrado.', null);
  //   } else {
  //     _alert(
  //         'Ocorreu um erro ao criar o usuário, tente novamente mais tarde.',
  //         resp.responseCode);
  //   }
  // }

  Future<void> _sendUserDetails() async {
    _loadingAlert('Criando usuário...');
    final resp = await _connector.postContentWithBody(
        '/api/v1/Usuario/persist', await _personalDetails.toJSONWithToken());
    print('DeviceToken: ${_personalDetails.toJSONWithToken()}');
    Navigator.pop(context);
    String? passwordToken;
    if (resp.responseCode! < 400) {
      Map parsedResp = jsonDecode(resp.returnBody!);
      passwordToken = parsedResp['codigoCadastroSenha'] as String?;
    } else if (resp.responseCode == 409) {
      _alert('Usuário já cadastrado.', null);
      return;
    } else {
      _alert('Ocorreu um erro ao criar o usuário, tente novamente mais tarde.',
          resp.responseCode);
      return;
    }
    _registerPassword(passwordToken);
  }

  // void _registerPassword(String token) async {
  //   _loadingAlert('Cadastrando senha...');
  //   final resp = await _connector.postContentWithBody(
  //       '/api/autenticacao/senha/criar',
  //       '{ "email": "${_personalDetails.email}", "novaSenha": "${_personalDetails.password.trim()}", "codigoCadastroSenha": "$token" }');
  //   Navigator.pop(context);
  //   if (resp.responseCode < 400) {
  //     _loadingAlert('Autenticando...');
  //     final login = await _connector.loginWithParams(LoginInput(
  //         login: _personalDetails.email, password: _personalDetails.password));
  //     Navigator.pop(context);
  //     if (login.responseCode < 400) {
  //       return _verifyAndSendIDPictures();
  //     } else {
  //       return _alert(
  //           'Ocorreu um erro de autenticação, tente novamente mais tarde.',
  //           login.responseCode);
  //     }
  //   } else {
  //     return _alert('Ocorreu um erro ao cadastrar a senha.', resp.responseCode);
  //   }
  // }

  Future<void> _registerPassword(String? token) async {
    _loadingAlert('Cadastrando senha...');
    final resp = await _connector.postContentWithBody(
        '/api/autenticacao/senha/criar',
        '{ "email": "${_personalDetails.email}", "novaSenha": "${_personalDetails.password!.trim()}", "codigoCadastroSenha": "$token" }');
    if (resp.responseCode! < 400) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      _alert('Ocorreu um erro ao cadastrar a senha.', resp.responseCode);
      return;
    }
    autenticarUser();
  }

  Future<void> autenticarUser() async {
    _loadingAlert('Autenticando...');
    final login = await _connector.loginWithParams(LoginInput(
        login: _personalDetails.email, password: _personalDetails.password));
    if (login.responseCode! < 400) {
      // await _connector.updateContent();
      // await User.fetch();
      Navigator.pop(context);
    } else {
      _alert('Ocorreu um erro de autenticação, tente novamente mais tarde.',
          login.responseCode);
      return;
    }
    _verifyAndSendIDPictures();
  }

  void _verifyAndSendIDPictures() async {
    String text;
    if (_personalDetails.idFront == null) {
      text = 'da frente';
    } else if (_personalDetails.idBack == null) {
      text = 'do verso';
    } else {
      return _sendIDPicture();
    }
    showDialog(
        builder: (context) => AlertDialog(
              actions: [
                FlatButton(
                    child: Text('Sim'),
                    onPressed: () {
                      Navigator.pop(context);
                      _sendIDPicture();
                    }),
                FlatButton(
                  child: Text('Adicionar'),
                  onPressed: () => Navigator.pop(context),
                )
              ].reversed.toList(),
              content: Text(
                  'Tem certeza que não deseja adicionar uma imagem $text do documento?'),
            ),
        barrierDismissible: false,
        context: context);
  }

  void _sendIDPicture() async {
    List<File?> images = [_personalDetails.idFront, _personalDetails.idBack];
    images.removeWhere((element) => element == null);
    if (images.length == 0) {
      _alert('Não existem documentos adicionados, por favor adicione!', 404);
      Navigator.pop(context);
    }
    _loadingAlert('Enviando imagens...');
    for (var img in images) {
      final resp = await _connector.uploadPicture(
          '/api/v1/Usuario/${User.instance!.id}/image', img!, {});
      Navigator.pop(context);
      if (resp.responseCode! < 400) {
        showDialog(
            builder: (context) {
              return AlertDialog(
                actions: [
                  FlatButton(
                    child: Text('Voltar'),
                    onPressed: () {
                      if (widget.isFromPurchase) {
                        Navigator.popUntil(
                            context, ModalRoute.withName('PurchaseRoute'));
                      } else {
                        Navigator.pop(context); // alerta
                        Navigator.pop(context); // essa tela
                        Navigator.pop(context); // tela de autenticação
                      }
                    },
                  )
                ],
                content: Text('Conta criada com sucesso!'),
              );
            },
            context: context);
      } else {
        _alert(
            'Ocorreu um erro ao enviar a imagem da identidade, tente novamente mais tarde.',
            resp.responseCode);
      }
    }
  }

  void _alert(String title, int? errCode) {
    showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                  child: Text('OK'), onPressed: () => Navigator.pop(context))
            ],
            content:
                Text('$title ${errCode != null ? '(Erro: $errCode)' : ''}'),
          );
        },
        context: context);
  }

  void _loadingAlert(String title) {
    showDialog(
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(255, 49, 49, 1) /* red */),
                ),
                SizedBox(height: 20.0),
                Text(title)
              ],
              mainAxisSize: MainAxisSize.min,
            ),
          );
        },
        context: context);
  }

  // void _showTerms() {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => AboutUsController(), fullscreenDialog: true));
  // }

  bool? shouldFixFlutter() {
    // basicamente fazemos o trabalho que o flutter devia fazer,
    // "levantar" a tela caso o textField não esteja visível nos
    // OSes que possuem o erro, mantendo o comportamento padrão nos
    // que não possuem.
    if (Platform.isAndroid) {
      Object? info = CurrentDeviceInfo().deviceInfo;
      if (info != null) {
        if (info is AndroidDeviceInfo) {
          // por enquanto, esse erro no teclado só ocorre em androids
          // com sdk < 30
          shouldFix = (info.version.sdkInt < 30);
        } else {
          print('what?');
        }
      } else {
        CurrentDeviceInfo()
            .getCurrentDeviceInfo()
            .then((_) => shouldFixFlutter());
      }
    } else {
      shouldFix = false;
    }
    return shouldFix;
  }

  void handleHideKeyboard() {
    bottomPadding = 0.0;
    if (shouldFix! && mounted) setState(() {});
  }

  void handleShowKeyboard(double kHeight) {
    if (shouldFix!) {
      bottomPadding = kHeight;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _keyboardUtils.removeAllKeyboardListeners();
    _keyboardUtils.dispose();
  }
}
