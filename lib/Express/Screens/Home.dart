
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:express/Express/CartProvider.dart';
import 'package:express/Express/Config/ConstantColor.dart';
import 'package:express/Express/Models/CartModel.dart';
import 'package:express/Express/Screens/DataScreen.dart';
import 'package:express/Express/Widgets/CartWidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../Config/ConstantSize.dart';

class HomeExpress extends StatefulWidget {
  const HomeExpress({super.key});

  @override
  State<HomeExpress> createState() => _HomeExpressState();
}

class _HomeExpressState extends State<HomeExpress> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var width = ConstantSize.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cart"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DataScreen()));
              },
              icon: CircleAvatar(
                radius: 35,
                backgroundColor: ConstantColor.colorOrangeTiger,
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ))
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('cart').snapshots(),
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
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0, childAspectRatio: 1.0),
                      itemCount: cartModel.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            showOption(cartModel[index]);
                          },
                          child: Card(
                            elevation: 3,
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: width! * 0.28,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            cartModel[index].image,
                                          ),
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    cartModel[index].name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            top: Platform.isAndroid ? ConstantSize.height! * 0.84 : ConstantSize.height! * 0.78,
            left: width! * 0.84,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('orders_placed').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(color: Colors.transparent,);
                  }
                  return snapshot.data!.docs.isNotEmpty
                      ? const CartWidget()
                      : Container(
                          color: Colors.transparent,
                        );
                }),
          )
        ],
      ),
    );
  }

  void showOption(CartModel cartModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<CartProvider>(builder: (context, ftProvider, _) {
          return AlertDialog(
            title: const Text('Select an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<int>(
                  title: const Text('Dry Cleaning'),
                  value: 1,
                  groupValue: ftProvider.getSelectedOption,
                  onChanged: (value) {
                    ftProvider.setSelectedOption = value!;
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Ironing'),
                  value: 2,
                  groupValue: ftProvider.getSelectedOption,
                  onChanged: (value) {
                    ftProvider.setSelectedOption = value!;

                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  addData(cartModel,ftProvider.getSelectedOption.toString());
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    backgroundColor: ConstantColor.colorOrangeTiger, // Set your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                    )),
                child: const Text(
                  "Add",
                  style: TextStyle(
                    color: Colors.white, // Set text color
                    fontSize: 16,
                  ),
                ),
              )
            ],
          );
        });
      },
    );
  }

  Future<List<int>> getImageBytes() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      return imageBytes;
    } else {
      throw Exception('No image selected');
    }
  }

  Future<void> addData(CartModel cartModel, String status) async {
    try {
      firestore.collection('orders_placed').doc(cartModel.id).set({
        'id': cartModel.id,
        'image': cartModel.image,
        'name': cartModel.name,
        'price': cartModel.price,
        'status': status,
        'counter': 1,
      });
      debugPrint("data_cart_saved_done");
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}
