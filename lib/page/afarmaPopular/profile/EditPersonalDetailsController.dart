import 'package:afarma/formatters/CPFFormatter.dart';
import 'package:afarma/formatters/PhoneFormatter.dart';
import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/helper/popularHelpers/CurrentDeviceInfo.dart';
import 'package:afarma/page/afarmaPopular/ViewImageWidget.dart';
import 'package:afarma/service/DocumentScanner.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:io';

class EditedPersonalDetails {
  User? user;

  String? _oldName;
  String? _name;
  String? get name => _name;
  set name(String? newName) {
    if (_name != null) {
      _oldName = '$_name';
    }
    ;
    _name = newName;
  }

  String? _oldCPF;
  String? _cpf;
  String? get cpf => _cpf;
  set cpf(String? newCPF) {
    if (_cpf != null) {
      _oldCPF = '$_cpf';
    }
    ;
    _cpf = newCPF;
  }

  String? _oldPhone;
  String? _phone;
  String? get phone => _phone;
  set phone(String? newPhone) {
    if (_phone != null) {
      _oldPhone = '$_phone';
    }
    ;
    _phone = newPhone;
  }

  String? _oldEmail;
  String? _email;
  String? get email => _email;
  set email(String? newEmail) {
    if (_email != null) {
      _oldEmail = '$_email';
    }
    ;
    _email = newEmail;
  }

  List<String?>? docIDs;
  List<File>? newDocs;

  List get docs => (docIDs ?? []) + (newDocs as List<String?>? ?? []);

  String toJSON() {
    return '{ "nome": "$_name", "cpf": "${_cpf!.trim()}", "email": "${_email!.trim()}", "telefone": "${_phone!.trim()}"';
  }

  String changesToJSON() {
    String ret = '{ "id": ${user!.id}';
    if (_oldName != null) {
      ret += ', "nome": "$_name"';
    }
    if (_oldCPF != null) {
      ret += ', "cpf": "$_cpf"';
    }
    if (_oldEmail != null) {
      ret += ' "nome": "$_name"';
    }
    if (_oldPhone != null) {
      ret += ', "telefone": "$_phone"';
    }
    ret += ' }';
    return ret;
  }

  static EditedPersonalDetails fromUser(User? usr) {
    final ret = EditedPersonalDetails();
    ret.user = usr;
    ret.populateFromUser();
    return ret;
  }

  void populateFromUser() {
    _name = user!.name;
    _cpf = user!.cpf;
    _phone = user!.cellphone;
    _email = user!.email;
    docIDs = user!.docIDs;
  }

  void applyChangesToUser() {
    if (_oldName != null) {
      user!.name = _name;
    }
    if (_oldCPF != null) {
      user!.cpf = _cpf;
    }
    if (_oldEmail != null) {
      user!.email = _email;
    }
    if (_oldPhone != null) {
      user!.cellphone = _phone;
    }
  }

  int docCount() => ((docIDs ?? []).length + (newDocs ?? []).length);
  bool hasDocs() => docCount() > 0;

  bool hasChanges() {
    return _oldName != null ||
        _oldCPF != null ||
        _oldEmail != null ||
        _oldPhone != null;
  }

  bool hasAddedDocs() => newDocs != null && newDocs!.length > 0;
}

class EditPersonalDetailsController extends StatefulWidget {
  @override
  _EditPersonalDetailsControllerState createState() =>
      _EditPersonalDetailsControllerState();
}

class _EditPersonalDetailsControllerState
    extends State<EditPersonalDetailsController> {
  KeyboardUtils _keyboardUtils = KeyboardUtils();
  double bottomPadding = 0.0;
  bool? shouldFix;

  Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  EditedPersonalDetails _personalDetails =
      EditedPersonalDetails.fromUser(User.instance);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    shouldFixFlutter();
    _keyboardUtils.add(
        listener: KeyboardListener(
            willHideKeyboard: handleHideKeyboard,
            willShowKeyboard: (kHeight) => handleShowKeyboard(kHeight)));
    _nameController.text = User.instance!.name!;
    _cpfController.text = CPFFormatter.format(User.instance!.cpf!);
    _phoneController.text = PhoneFormatter.format(User.instance!.cellphone);
    _emailController.text = User.instance!.email!;
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
        padding: EdgeInsets.only(top: 20.0, bottom: bottomPadding),
      ),
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            child: Column(
              children: [
                _textField(
                    'Nome Completo', _nameController, [], TextInputType.name,
                    (val) {
                  _personalDetails.name = val;
                }, null),
                _textField('CPF', _cpfController, [_cpfFormatter],
                    TextInputType.number, (val) {
                  _personalDetails.cpf = _cpfFormatter.getUnmaskedText();
                }, null),
                _textField('Celular', _phoneController, [_phoneFormatter],
                    TextInputType.number, (val) {
                  _personalDetails.phone = _phoneFormatter.getUnmaskedText();
                },
                    Text(
                      'Insira um número com DDD e 9 dígitos',
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    )),
                _textField(
                    'Email', _emailController, [], TextInputType.emailAddress,
                    (val) {
                  _personalDetails.email = val;
                }, null),
                _idWidget()
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
          SizedBox(height: 20.0)
        ],
      ),
    );
  }

  Widget _idWidget() {
    List<Widget> docWidgets = [];
    if (_personalDetails.docIDs != null) {
      _personalDetails.docIDs!.forEach((doc) {
        docWidgets.add(GestureDetector(
          child: Padding(
            child: Image(
                image: NetworkImage(DefaultURL.apiURL() +
                    DefaultURI.afarma +
                    '/api/v1/Documento/image/$doc'),
                height: 150,
                width: 150),
            padding: EdgeInsets.only(right: 20.0),
          ),
          onTap: () => _idImageOptions(null, doc),
        ));
      });
    }
    if (_personalDetails.newDocs != null) {
      _personalDetails.newDocs!.forEach((doc) {
        docWidgets.add(GestureDetector(
            child: Padding(
              child: Image(image: FileImage(doc), height: 150, width: 150),
              padding: EdgeInsets.only(right: 20.0),
            ),
            onTap: () => _idImageOptions(doc, null)));
      });
    }

    return _personalDetails.hasDocs()
        ? Container(
            child: Column(
              children: [
                Text('Documento${_personalDetails.docCount() > 1 ? 's' : ''}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 20.0),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: docWidgets,
                      mainAxisAlignment: MainAxisAlignment.center,
                    )),
                SizedBox(height: 20.0),
                Center(
                  child: ButtonTheme(
                    child: RaisedButton(
                      child: Text(
                        'Adicionar',
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      color: Colors.red,
                      onPressed: () => _addIDPicture(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 2))
                ],
                color: Colors.white),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40,
          )
        : Column(
            children: [
              Row(children: [
                Text('Foto do documento',
                    style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Spacer(),
                ButtonTheme(
                    child: RaisedButton(
                        child: Row(children: [
                          Icon(
                            Icons.attach_file,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Anexar', //_personalDetails.idImage != null ? 'Mudar' : 'Anexar',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                        color: Color.fromRGBO(67, 67, 67, 1),
                        /* dark grey */
                        onPressed: () => _addIDPicture(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))))
              ]),
              Divider(
                color: Colors.grey.withOpacity(0.6),
                thickness: 1.0,
              )
            ],
          );
  }

  void _addIDPicture() async {
    File pickedImage;
    bool isSimulator;
    if (Platform.isIOS) {
      IosDeviceInfo deviceInfo =
          CurrentDeviceInfo().deviceInfo as IosDeviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo deviceInfo =
          CurrentDeviceInfo().deviceInfo as AndroidDeviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    }
    pickedImage = await _getImage('photo', context);
    _addPicture(pickedImage);
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
    PickedFile image = await ImagePicker().getImage(source: src);
    return image;
  }
  */
  Future<File> _getImage(String typeScan, context) async {
    File image = await DocumentScanner.getDocument(typeScan, context);
    return image;
  }

  void _addPicture(File pickedImage) {
    if (pickedImage != null) {
      if (_personalDetails.newDocs == null) _personalDetails.newDocs = [];
      _personalDetails.newDocs!.add(pickedImage);
      if (mounted) setState(() {});
    }
  }

  void _idImageOptions(File? docFile, String? docID) async {
    final a = await showModalBottomSheet(
        builder: (context) => Container(
              child: Column(
                children: [
                  GestureDetector(
                    child: Image(
                      image: ((docFile != null)
                              ? FileImage(docFile)
                              : NetworkImage(DefaultURL.apiURL() +
                                  DefaultURI.afarma +
                                  '/api/v1/Documento/image/$docID'))
                          as ImageProvider<Object>,
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
                          onPressed: () async {
                            if (docFile != null) {
                              _personalDetails.newDocs!.remove(docFile);
                            } else {
                              _loadingAlert('Apagando...');
                              final resp = await _connector
                                  .deleteContent('/api/v1/Documento/$docID');
                              Navigator.pop(context);
                              if (resp.responseCode! >= 400) {
                                _alert('Ocorreu um erro ao apagar o documento',
                                    resp.responseCode);
                              } else {
                                _personalDetails.docIDs!.remove(docID);
                              }
                            }
                            Navigator.pop(context);
                            setState(() {});
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
                            Get.to(
                                ViewImageWidget(
                                  image: ((docFile != null)
                                          ? FileImage(docFile)
                                          : NetworkImage(DefaultURL.apiURL() +
                                              DefaultURI.afarma +
                                              '/api/v1/Documento/image/$docID'))
                                      as ImageProvider<Object>?,
                                ),
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

  Widget _textField(
      String title,
      TextEditingController controller,
      List<TextInputFormatter> formatters,
      TextInputType keyboardType,
      Function(String) onSubmitted,
      Widget? bottom) {
    final ret = TextField(
      autocorrect: false,
      autofocus: false,
      controller: controller,
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

  void _saveAndQuit() async {
    if (_personalDetails.hasChanges()) {
      await _updateUserDetails();
    }
    if (_personalDetails.hasAddedDocs()) {
      await _updateUserIDs();
    }
    await User.fetch();
    Navigator.pop(context);
  }

  Future<void> _updateUserDetails() async {
    _loadingAlert('Enviando mudanças...');
    String body = _personalDetails.changesToJSON();
    final resp =
        await _connector.putContentWithBody('/api/v1/Usuario/mergehalf', body);
    Navigator.pop(context);
    if (resp.responseCode! < 400) {
      _personalDetails.applyChangesToUser();
    } else {
      _alert(
          'Ocorreu um erro ao salvar suas alterações, tente novamente mais tarde',
          resp.responseCode);
    }
  }

  Future<void> _updateUserIDs() async {
    int count = 1;
    for (File newDoc in _personalDetails.newDocs!) {
      _loadingAlert(
          'Enviando foto $count de ${_personalDetails.newDocs!.length}');
      final resp = await _connector.uploadPicture(
          '/api/v1/Usuario/${User.instance!.id}/image', newDoc, {});
      Navigator.pop(context);
      if (resp.responseCode! < 400) {
        count++;
      } else {
        _alert('Ocorreu um erro ao enviar a ${count}ª nova foto do documento',
            resp.responseCode);
        count = -1;
        return;
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

  void _fetchIDPicture() async {}

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
