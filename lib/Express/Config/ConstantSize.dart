import 'package:flutter/material.dart';

class ConstantSize {
  static MediaQueryData? _mediaQueryData;
  static double? width;
  static double? height;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData!.size.width;
    height = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;
  }
}
