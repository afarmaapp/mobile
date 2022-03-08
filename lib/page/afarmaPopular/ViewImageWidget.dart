import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ViewImageWidget extends StatelessWidget {

  final ImageProvider? image;

  ViewImageWidget({this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: image,
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }

}