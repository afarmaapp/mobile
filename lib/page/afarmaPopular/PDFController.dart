// import 'dart:async';
// import 'dart:io';
// import 'package:afarma/LoginController.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
// import 'package:path_provider/path_provider.dart';

// class PDFController extends StatefulWidget {

//   String pdfURL;
//   bool isLocalFile = false;
//   bool displayAppBar = false;
//   String title;
//   PDFController({this.pdfURL, this.isLocalFile, this.displayAppBar, this.title});

//   @override 
//   _PDFControllerState createState() => _PDFControllerState();

// }

// class _PDFControllerState extends State<PDFController> {

//   String pdfPath;

//   @override 
//   void initState() {
//     super.initState();
//     if (widget.isLocalFile) {
//       pdfPath = widget.pdfURL;
//     } else {
//       createFileOfPdfUrl().then((file) {
//         setState(() {
//           pdfPath = file.path;
//         });
//       });
//     }
  
//   }

//   Future<File> createFileOfPdfUrl() async {
//     final url = widget.pdfURL;
//     final filename = url.substring(url.lastIndexOf("/") + 1).split("?")[0];
//     // final filename = url.substring(url.lastIndexOf("/") + 1);
//     var request = await HttpClient().getUrl(Uri.parse(url));
//     var response = await request.close();
//     var bytes = await consolidateHttpClientResponseBytes(response);
//     String dir = (await getApplicationDocumentsDirectory()).path;
//     File file = new File('$dir/$filename');
//     await file.writeAsBytes(bytes);
//     return file;
//   }

//    @override 
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.displayAppBar
//         ? AppBar(
//             elevation: 0,
//             iconTheme: IconThemeData(color: Colors.white)
//           )
//         : null,  
//       body: (pdfPath == null ? _loading() : _mainWidget(widget.title))
//     );
//   }

//   Widget _mainWidget(title) {
//     return PDFViewerScaffold(
//       appBar: widget.displayAppBar
//         ? PreferredSize(
//             preferredSize: Size.fromHeight(100.0), // here the desired height
//             child: AppBar(
//               backgroundColor: Color.fromRGBO(51, 147, 217, 1),
//               elevation: 0,
//               iconTheme: IconThemeData(color: Colors.white)
//             ),
//           )
//         : PreferredSize(
//             preferredSize: Size.fromHeight(0),
//             child: Container(),
//           ),
//       path: pdfPath,
//       primary: false
//     );
//   }
  

//   Widget _loading() {
//     return Container(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.red)
//           ),
//           SizedBox(height: 20.0),
//           Text(
//             'Carregando informações...',
//             style: TextStyle(
//               color: Colors.black
//             )
//           )
//         ],
//       ),
//       width: MediaQuery.of(context).size.width,

//     );
//   }
// }