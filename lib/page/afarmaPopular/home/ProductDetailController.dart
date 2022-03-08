import 'package:afarma/model/popularModels/Medication.dart';
import 'package:afarma/repository/popularRepositories/Cart.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ProductDetailController extends StatefulWidget {
  ProductDetailController({this.product});

  final Medication? product;

  @override
  _ProductDetailControllerState createState() =>
      _ProductDetailControllerState();
}

class _ProductDetailControllerState extends State<ProductDetailController> {
  Medication? get _med => widget.product;

  bool get _isFromCart => Cart().meds!.contains(widget.product);

  int? _amountToAdd;
  bool get _canChangeAmount => true;

  //int _amountToAdd = 3;

  @override
  void initState() {
    super.initState();
    if (_isFromCart) {
      _amountToAdd = Cart().amounts![Cart().meds!.indexOf(_med)];
    } else {
      _amountToAdd = _canChangeAmount
          ? widget.product!.allowedAmount
          : widget.product!.allowedAmount;
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
    return Container(
      child: Hero(
        child: Image(
          fit: BoxFit.cover,
          image: _med!.medImage(),
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
        ),
        tag: _med!.id!,
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
          _inputWidgets(),
          SizedBox(height: 20.0)
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        color: Color.fromRGBO(255, 49, 49, 1), /* red */
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
            _med!.name!,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: AutoSizeText(_med!.amount!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w200),
              maxLines: 1,
              textAlign: TextAlign.left),
        ),
      ],
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
          _med!.description!,
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
              if (_canChangeAmount && _amountToAdd! > 1) {
                _amountToAdd! - 1;
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
                _amountToAdd! + 1;
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
        color: Color.fromRGBO(0, 169, 211, 1) /* blue */,
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
      if (Cart().amounts![Cart().meds!.indexOf(_med)] != _amountToAdd) {
        return 'Alterar quantidade';
      }
      return 'Remover da cesta';
    }
    return 'Adicionar a cesta';
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
      if (Cart().amounts![Cart().meds!.indexOf(_med)] != _amountToAdd) {
        Cart().amounts![Cart().meds!.indexOf(_med)] = _amountToAdd;
        Navigator.pop(context);
        return;
      }
      Cart().removeMed(_med);
    } else {
      Cart().addMedication(_med, _amountToAdd);
    }
    Navigator.pop(context, ret);
  }
}
