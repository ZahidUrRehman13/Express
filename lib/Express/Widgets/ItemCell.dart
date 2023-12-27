import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:express/Express/CartProvider.dart';
import 'package:express/Express/Config/ConstantSize.dart';
import 'package:express/Express/Models/CartModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ItemCell extends StatefulWidget {
  CartModel cartModel;
  bool isLast;
  ItemCell({super.key, required this.cartModel, required this.isLast});

  @override
  State<ItemCell> createState() => _ItemCellState();
}

class _ItemCellState extends State<ItemCell> {
  final FirebaseFirestore firebaseFire = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var height = ConstantSize.height;
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Container(
        height: height! * 0.12,
        margin: const EdgeInsets.only(top: 12, bottom: 0, right: 12, left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.cartModel.name.trim(),
                  maxLines: 2,
                ),
                Text(
                  widget.cartModel.status == "1" ? "Dry Wash" : 'Ironing',
                ),
                Text(
                  'AED ${widget.cartModel.price}' ?? '',
                  maxLines: 2,
                ),
              ],
            ),
            counterWidget(widget.cartModel),
            Visibility(
              visible: !widget.isLast,
              child: const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Divider(
                  height: 0.5,
                  thickness: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget counterWidget(CartModel cartModel) {
    int value = widget.cartModel.counter!;
    return Container(
      width: 130,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.black12,
        border: Border.all(width: 0, color: Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (value > 1) {
                setState(() {
                  value--;
                });
              } else {
                setState(() {
                  value--;
                });
                updateCounter(cartModel.id, 0);
              }
              updateCounter(cartModel.id, value);
            },
            icon: const Icon(
              Icons.remove_circle,
              size: 22,
            ),
          ),
          Text(widget.cartModel.counter.toString()),
          IconButton(
            onPressed: () {
              setState(() {
                value++;
              });
              updateCounter(cartModel.id, value);
            },
            icon: const Icon(
              Icons.add_circle,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateCounter(String docId, int value) async {
    try {
      DocumentReference docRef = firebaseFire.collection('orders_placed').doc(docId);

      await docRef.update({
        'counter': value,
      });
      _fetchItems(value);
      debugPrint('value updated successfully');
    } catch (e) {
      debugPrint('Error updating field: $e');
    }
  }

  Future<void> _fetchItems(int value) async {
    double pricePerItem = 0.0;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders_placed').get();

      querySnapshot.docs.forEach((item) {
        pricePerItem += double.parse(item['price']) * item['counter'];
      });

      if (context.mounted) {
        context.read<CartProvider>().setTotalPrice = pricePerItem;
      }

      if (value == 0) {
        await FirebaseFirestore.instance.collection('orders_placed').doc(widget.cartModel.id).delete();
      }

      debugPrint('totalPrice: $pricePerItem');
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }
}
