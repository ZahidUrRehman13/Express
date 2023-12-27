import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:express/Express/CartProvider.dart';
import 'package:express/Express/Config/ConstantColor.dart';
import 'package:express/Express/Config/ConstantSize.dart';
import 'package:express/Express/Models/CartModel.dart';
import 'package:express/Express/Widgets/ItemCell.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {


  @override
  void initState() {
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     _fetchItems();

   });
    super.initState();
  }

  Future<void> _fetchItems() async {
    double pricePerItem = 0.0;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders_placed').get();

      querySnapshot.docs.forEach((item) {
        pricePerItem += double.parse(item['price'])*item['counter'];
      });

      if(context.mounted){
        context.read<CartProvider>().setTotalPrice=pricePerItem;
      }

      debugPrint('totalPrice: $pricePerItem');
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var height = ConstantSize.height;
    var width = ConstantSize.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cart"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Wrap(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                'Your Order',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(
              height: height! * 0.78,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('orders_placed').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: ConstantColor.colorOrangeTiger,
                        size: 100,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No Data found.'));
                  } else {
                    List<CartModel> cartModel = snapshot.data!.docs.map((doc) => CartModel.fromJson(doc.data())).toList();

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cartModel.length,
                          itemBuilder: (BuildContext context, index) {
                            return ItemCell(
                              cartModel: cartModel[index],
                              isLast: index == cartModel.length - 1,
                            );
                          }),
                    );
                  }
                },
              ),
            ),
            Container(
              width: width,
              height: height * 0.1,
              color: ConstantColor.colorOrangeTiger,
              child: Stack(
                children: [
                  Positioned(
                    right: 10.0,
                    top: 5.0,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          backgroundColor: ConstantColor.colorWhite, // Set your desired background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                          )),
                      child: const Text(
                        "Print",
                        style: TextStyle(
                          color: Colors.black, // Set text color
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    left: 10.0,
                    child: Consumer<CartProvider>(
                      builder: (context, data,_) {
                        return Text(
                          data.getTotalPrice.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
