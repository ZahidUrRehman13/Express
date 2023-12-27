import 'package:flutter/cupertino.dart';


class ImageAssetWidget extends StatelessWidget {
  String imagePath;
  BoxFit boxFit;
  double height;
  double width;
   ImageAssetWidget({super.key,required this.imagePath, required this.height, required this.width, this.boxFit=BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return   Container(
      height: height,
      width: width,
      decoration:  BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imagePath),
              fit: boxFit
          )
      ),
    );
  }
}
