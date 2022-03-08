// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebController extends StatefulWidget {
//   WebController({required this.initialURL, required this.displayAppBar});

//   final String? initialURL;
//   final bool displayAppBar;

//   @override
//   _WebControllerState createState() => _WebControllerState();
// }

// class _WebControllerState extends State<WebController> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: getAppBar() as PreferredSizeWidget?,
//       body: WebView(
//         initialUrl: widget.initialURL,
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }

//   Widget? getAppBar() {
//     if (widget.displayAppBar) {
//       return AppBar();
//     } else {
//       return null;
//     }
//   }
// }
