import 'package:auto_size_text/auto_size_text.dart';

import 'floating_navbar_item.dart';
import 'package:flutter/material.dart';

typedef Widget ItemBuilder(BuildContext context, FloatingNavbarItem items);

class FloatingNavbar extends StatefulWidget {
  final List<FloatingNavbarItem> items;
  final int currentIndex;
  final void Function(int val) onTap;
  final Color selectedBackgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color backgroundColor;
  final double fontSize;
  final double iconSize;
  final double itemBorderRadius;
  final double borderRadius;
  final ItemBuilder itemBuilder;
  final bool displayTitle;

  FloatingNavbar(
      {Key? key,
      required this.items,
      required this.currentIndex,
      required this.onTap,
      ItemBuilder? itemBuilder,
      this.backgroundColor = Colors.black,
      this.selectedBackgroundColor = Colors.white,
      this.selectedItemColor = Colors.black,
      this.iconSize = 24.0,
      this.fontSize = 9.0,
      this.borderRadius = 8,
      this.itemBorderRadius = 8,
      this.unselectedItemColor = Colors.white,
      this.displayTitle = true})
      : assert(items.length > 1),
        assert(items.length <= 5),
        assert(currentIndex <= items.length),
        itemBuilder = itemBuilder ??
            _defaultItemBuilder(
              unselectedItemColor: unselectedItemColor,
              selectedItemColor: selectedItemColor,
              borderRadius: borderRadius,
              fontSize: fontSize,
              backgroundColor: backgroundColor,
              currentIndex: currentIndex,
              iconSize: iconSize,
              itemBorderRadius: itemBorderRadius,
              items: items,
              onTap: onTap,
              selectedBackgroundColor: selectedBackgroundColor,
              displayTitle: displayTitle,
            ),
        super(key: key);

  @override
  _FloatingNavbarState createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar> {
  List<FloatingNavbarItem> get items => widget.items;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Container(
                  padding: EdgeInsets.only(bottom: 15, top: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      color: widget.backgroundColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 2))
                      ]),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: items.map((f) {
                        return widget.itemBuilder(context, f);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

ItemBuilder _defaultItemBuilder({
  required Function(int val) onTap,
  required List<FloatingNavbarItem> items,
  required int currentIndex,
  required Color selectedBackgroundColor,
  required Color selectedItemColor,
  required Color unselectedItemColor,
  required Color backgroundColor,
  required double fontSize,
  required double iconSize,
  required double itemBorderRadius,
  required double borderRadius,
  required bool displayTitle,
}) {
  return (BuildContext context, FloatingNavbarItem item) => Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  color: currentIndex == items.indexOf(item)
                      ? selectedBackgroundColor
                      : backgroundColor,
                  borderRadius: BorderRadius.circular(itemBorderRadius)),
              child: InkWell(
                onTap: () {
                  onTap(items.indexOf(item));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    //max-width for each item
                    //24 is the padding from left and right
                    // * 110 instead of * 100 fixed the 'overflow by 5 pixels issue
                    width: MediaQuery.of(context).size.width *
                            (100 / (items.length * 110)) -
                        15,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            item.image != null
                                ? Container(
                                    height: iconSize * 1.6,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(<double>[
                                        0.2126,
                                        0.7152,
                                        0.0722,
                                        0,
                                        0,
                                        0.2126,
                                        0.7152,
                                        0.0722,
                                        0,
                                        0,
                                        0.2126,
                                        0.7152,
                                        0.0722,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                      ]),
                                      //     currentIndex == items.indexOf(item)
                                      //         ? ColorFilter.mode(
                                      //             Colors.transparent,
                                      //             BlendMode.multiply,
                                      //           )
                                      //         : ColorFilter.matrix(<double>[
                                      //             0.2126,
                                      //             0.7152,
                                      //             0.0722,
                                      //             0,
                                      //             0,
                                      //             0.2126,
                                      //             0.7152,
                                      //             0.0722,
                                      //             0,
                                      //             0,
                                      //             0.2126,
                                      //             0.7152,
                                      //             0.0722,
                                      //             0,
                                      //             0,
                                      //             0,
                                      //             0,
                                      //             0,
                                      //             1,
                                      //             0,
                                      //           ]),
                                      child: Container(child: item.image),
                                    ),
                                  )
                                : Icon(
                                    item.icon,
                                    color: currentIndex == items.indexOf(item)
                                        ? (item.selectedColor != null
                                            ? item.selectedColor
                                            : selectedItemColor)
                                        : (item.unselectedColor != null
                                            ? item.unselectedColor
                                            : unselectedItemColor),
                                    size: iconSize,
                                  ),
                            (displayTitle && item.title != null)
                                ? AutoSizeText(
                                    (item.title != null ? item.title : '')!,
                                    minFontSize: 10,
                                    style: TextStyle(
                                        color:
                                            currentIndex == items.indexOf(item)
                                                ? selectedItemColor
                                                : unselectedItemColor),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  )
                                : Container()
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        item.count == 0
                            ? Container()
                            : Positioned(
                                top: 0,
                                right: 15,
                                child: new Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: new BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: new Text(
                                    item.count == -1
                                        ? ''
                                        : item.count.toString(),
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      );
}
