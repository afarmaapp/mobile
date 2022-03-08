import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Cart.dart';
import 'package:afarma/model/Medication.dart';
import 'package:afarma/repository/MedicationRepository.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({required this.product, this.isFromPromo = false});

  final Medication product;
  bool isFromPromo;

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Medication get _med => widget.product;

  bool get _isFromCart => Cart().meds.contains(widget.product);

  int _amountToAdd = 1;
  bool get _canChangeAmount => true;

  @override
  void initState() {
    super.initState();
    if (_isFromCart) {
      _amountToAdd = Cart().amounts[Cart().meds.indexOf(_med)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.red),
      ),
      body: Container(
        child: _mainBody(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
    );
  }

  Widget _mainBody() {
    return Column(
      children: [
        _medImage(),
        _medInfo(),
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }

  Widget _medImage() {
    double? height = MediaQuery.of(context).size.height / 2;
    double? width = MediaQuery.of(context).size.width;

    return Container(
      child: Hero(
        child: _med.medImageSized(width, height, BoxFit.cover),
        tag: _med.id +
            "-details-" +
            DateTime.now().microsecondsSinceEpoch.toString(),
      ),
      decoration: BoxDecoration(color: Colors.white),
    );
  }

  Widget _medInfo() {
    return Container(
      child: Column(
        children: [
          _medTitle(),
          Spacer(flex: 1),
          _medDescription(),
          Spacer(flex: 2),
          _medPrice(),
          Spacer(flex: 2),
          _inputWidgets(),
          SizedBox(height: 30.0)
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        color: AppColors.primary, /* red */
      ),
      height: MediaQuery.of(context).size.height / 2,
      padding: EdgeInsets.only(
        //bottom: 20.0,
        left: 20.0,
        right: 20.0,
        top: 20.0,
      ),
    );
  }

  Widget _medTitle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            _med.nome,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _medPrice() {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "A partir de: " + _med.getPrecoMedioFormated(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              widget.isFromPromo
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 2,
                            color: Color(0xFFFDD835),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.yellow[600],
                            size: 16,
                          ),
                          Text('PROMO',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.yellow[600],
                                  fontWeight: FontWeight.w700)),
                        ],
                      ))
                  : Container()
            ],
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _medDescription() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Descrição do Produto',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 15),
        AutoSizeText(
          _med.descricao,
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
          maxLines: 5,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _inputWidgets() {
    return Row(
      children: [
        Expanded(
          child: _amount(),
          flex: 35,
        ),
        Spacer(flex: 5),
        Expanded(
          child: _addToBasketButton(),
          flex: 60,
        )
      ],
    );
  }

  Widget _amount() {
    // return widget.product.segment.order != 4 ?
    // AutoSizeText(
    //   'Quantidade : ${widget.product.allowedAmount}',
    //   style: TextStyle(
    //     color: Colors.white,
    //     fontWeight: FontWeight.w700
    //   ),
    //   maxLines: 1,
    // ) :
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.white),
            onPressed: () {
              if (_canChangeAmount && _amountToAdd > 1) {
                _amountToAdd--;
                setState(() {});
              }
            }),
        Padding(
          child: Text(
            _amountToAdd.toString(),
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          padding: EdgeInsets.only(left: 3.0, right: 3.0),
        ),
        IconButton(
            icon: Icon(Icons.add_circle, color: Colors.white),
            onPressed: () {
              if (_canChangeAmount) {
                _amountToAdd++;
                setState(() {});
              }
            })
      ],
    );
  }

  Widget _addToBasketButton() {
    return ButtonTheme(
      child: RaisedButton(
        child: Row(
          children: [
            Text(
              _addToBasketButtonText(),
              style: TextStyle(color: Colors.white),
            ),
            Icon(
              (_isFromCart
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline),
              color: Colors.white,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        color: AppColors.secondary /* blue */,
        onPressed: () => _updateCartAndExit(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      height: 50,
    );
  }

  String _addToBasketButtonText() {
    if (_isFromCart) {
      // if (_med.segment.order == 4) {
      //   if (Cart().amounts[Cart().meds.indexOf(_med)] != _amountToAdd) {
      //     return 'Alterar quantidade';
      //   }
      // }
      if (Cart().amounts[Cart().meds.indexOf(_med)] != _amountToAdd) {
        return 'Alterar Quantidade';
      }
      return 'Remover da Cesta';
    }
    return 'Adicionar a Cesta';
  }

  void _updateCartAndExit() {
    bool ret = !_isFromCart;
    if (_isFromCart) {
      // if (_med.segment.order == 4) {
      //   if (Cart().amounts[Cart().meds.indexOf(_med)] != _amountToAdd) {
      //     Cart().amounts[Cart().meds.indexOf(_med)] = _amountToAdd;
      //     Navigator.pop(context);
      //     return;
      //   }
      // }
      if (Cart().amounts[Cart().meds.indexOf(_med)] != _amountToAdd) {
        Cart().amounts[Cart().meds.indexOf(_med)] = _amountToAdd;
        Navigator.pop(context);
        return;
      }
      Cart().removeMed(_med);
    } else {
      if (widget.isFromPromo) {
        Cart().addMedication(_med, _amountToAdd, promo: true);
      } else {
        Cart().addMedication(_med, _amountToAdd);
      }

      if (_med.lojaPromocao != null && _med.lojaPromocao != '') {
        MedicationRepository().setFarmaciaPromocao(_med.lojaPromocao!);
      }
    }
    Navigator.pop(context, ret);
  }
}
