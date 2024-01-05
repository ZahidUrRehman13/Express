import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  int maxline;
  String text;
  TextStyle textStyle;
  bool alignmentCenter;
  TextWidget(
      {super.key,
      required this.text,
      this.textStyle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500,fontFamily: "Sans"),
      this.maxline = 1,
      this.alignmentCenter=false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyle,
      maxLines: maxline,
      overflow: TextOverflow.ellipsis,
      textAlign: alignmentCenter ? TextAlign.center:TextAlign.start,
    );
  }
}
