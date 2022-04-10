import 'package:app/modules/cart/models/cotation/cotation_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CotationCard extends StatefulWidget {
  const CotationCard({
    Key? key,
    required this.cotation,
  }) : super(key: key);

  final Cotation cotation;

  @override
  State<CotationCard> createState() => _CotationCardState();
}

class _CotationCardState extends State<CotationCard> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      enableFeedback: false,
      offset: const Offset(0, 70),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 1.0)),
        child: Column(
          children: [
            Center(
                child: Image.asset(
              'assets/images/${widget.cotation.loja == "AFARMA" ? "logo-red.png" : "logo-raia.png"}',
              fit: BoxFit.fitWidth,
            )),
            const SizedBox(height: 10.0),
            SizedBox(
              width: 70,
              child: AutoSizeText(
                NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                    .format(widget.cotation.total),
                maxLines: 1,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      ),
      itemBuilder: (context) {
        return List.generate(
          widget.cotation.itens.length,
          (index) => index == 0
              ? PopupMenuItem(
                  child: Container(
                    width: 500,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          widget.cotation.loja == "AFARMA"
                              ? "assets/images/logo-red.png"
                              : "assets/images/logo-raia.png",
                          height: 30,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.cotation.itens[index].nome,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              widget.cotation.itens[index].quantidade
                                      .toString() +
                                  'x',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              NumberFormat.currency(
                                      locale: 'pt_BR', symbol: 'R\$')
                                  .format(widget.cotation.itens[index].valor),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : PopupMenuItem(
                  child: Container(
                    width: 500,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.cotation.itens[index].nome,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: true,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          widget.cotation.itens[index].quantidade.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                              .format(widget.cotation.itens[index].valor),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // var cFarmaciaMenorValor = PopupMenuButton(
  //       enableFeedback: false,
  //       // enabled: false,
  //       offset: Offset(0, 70),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(10.0),
  //         ),
  //       ),
  //       child: Stack(
  //         children: [
  //           Container(
  //             width: widthFarmacia,
  //             padding: EdgeInsets.all(15),
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 color: Colors.white,
  //                 border: Border.all(color: Colors.red, width: 3.0)),
  //             child: Column(
  //               children: [
  //                 Center(
  //                     child: Image.asset(
  //                   'assets/images/' + logo,
  //                   fit: BoxFit.fitWidth,
  //                 )),
  //                 // SizedBox(height: 5.0),
  //                 // AutoSizeText(
  //                 //   farmacia["loja"],
  //                 //   style: TextStyle(fontWeight: FontWeight.w400),
  //                 //   textAlign: TextAlign.center,
  //                 //   maxLines: 1,
  //                 // ),
  //                 SizedBox(height: 10.0),
  //                 Text(
  //                   valorMaskControlller.text,
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Positioned(
  //               bottom: 0,
  //               child: Container(
  //                 alignment: Alignment.center,
  //                 padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1),
  //                 width: 100,
  //                 decoration: BoxDecoration(
  //                     color: Colors.red,
  //                     borderRadius: BorderRadius.only(
  //                         bottomLeft: Radius.circular(10),
  //                         bottomRight: Radius.circular(10))),
  //                 child: Text("MENOR PREÇO",
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w600,
  //                     )),
  //               ))
  //         ],
  //       ),
  //       itemBuilder: (context) {
  //         return List.generate(
  //           items.length,
  //           (index) => index == 0
  //               ? PopupMenuItem(
  //                   child: Container(
  //                     width: 500,
  //                     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: Colors.transparent,
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         Image.asset(
  //                           farmacia["loja"] == "VENANCIO"
  //                               ? "assets/images/logo-venancio.png"
  //                               : (farmacia["loja"] == "PACHECO"
  //                                   ? "assets/images/logo-pacheco.png"
  //                                   : "assets/images/logo-raia.png"),
  //                           height: 30,
  //                         ),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Row(
  //                           children: [
  //                             Center(
  //                               child: Icon(Icons.add_circle_outline,
  //                                   color: (Colors.red[300]), size: 27),
  //                             ),
  //                             SizedBox(width: 5.0),
  //                             Flexible(
  //                               child: Text(
  //                                 '${items[index]["a$index" + "nome_$index"]}',
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 2,
  //                                 softWrap: true,
  //                                 style: TextStyle(fontWeight: FontWeight.bold),
  //                               ),
  //                             ),
  //                             SizedBox(width: 5.0),
  //                             Text(
  //                               '${items[index]["qtde_$index"]}',
  //                               style: TextStyle(fontWeight: FontWeight.bold),
  //                             ),
  //                             SizedBox(width: 5.0),
  //                             Text(
  //                               valueItemFormat(
  //                                   items[index]["a${index}valor_$index"]),
  //                               style: TextStyle(fontWeight: FontWeight.bold),
  //                             )
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 )
  //               : PopupMenuItem(
  //                   child: Container(
  //                     width: 500,
  //                     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: Colors.transparent,
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Center(
  //                           child: Icon(Icons.add_circle_outline,
  //                               color: (Colors.red[300]), size: 27),
  //                         ),
  //                         SizedBox(width: 5.0),
  //                         Flexible(
  //                           child: Text(
  //                             '${items[index]["a$index" + "nome_$index"]}',
  //                             overflow: TextOverflow.ellipsis,
  //                             maxLines: 2,
  //                             softWrap: true,
  //                             style: TextStyle(fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         SizedBox(width: 5.0),
  //                         Text(
  //                           '${items[index]["qtde_$index"]}',
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                         SizedBox(width: 5.0),
  //                         Text(
  //                           valueItemFormat(
  //                               items[index]["a${index}valor_$index"]),
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //         );
  //       },
  //     );
}
