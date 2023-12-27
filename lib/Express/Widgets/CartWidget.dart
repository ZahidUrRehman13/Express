import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:express/Express/Config/ConstantColor.dart';
import 'package:express/Express/Config/ConstantSize.dart';
import 'package:express/Express/Screens/Cart.dart';
import 'package:express/Express/Widgets/ImageAssetWidgets.dart';
import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var height = ConstantSize.height;
    var width = ConstantSize.width;
    return InkWell(
      onTap: () {
        Navigator.push(context, (MaterialPageRoute(builder: (context) => const Cart())));
      },
      child: ScaleAnimation(
        curve: Curves.bounceOut,
        child: Container(
          height: height! * 0.05,
          width: width! * 0.18,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            color: ConstantColor.colorWhite,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [ImageAssetWidget(imagePath: "assets/shopping.png", height: 35, width: 35), const SizedBox()],
          ),
        ),
      ),
    );
  }
}
