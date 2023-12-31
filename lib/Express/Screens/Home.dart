import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:express/Express/CartProvider.dart';
import 'package:express/Express/Config/ConstantColor.dart';
import 'package:express/Express/Models/CartModel.dart';
import 'package:express/Express/Screens/DataScreen.dart';
import 'package:express/Express/Screens/History.dart';
import 'package:express/Express/Widgets/CartWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../Config/ConstantSize.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _advancedDrawerController = AdvancedDrawerController();
  late final int columnRatio;

  double kMobileBreakpoint = 576;
  double kTabletBreakpoint = 1024;
  double kDesktopBreakPoint = 1366;

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var width = ConstantSize.width;
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white],
          ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 128.0,
                height: 128.0,
                margin: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 64.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/baghasht.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              ListTile(
                onTap: () {
                  _advancedDrawerController.hideDrawer();
                },
                leading: const Icon(Icons.home),
                title: const Text(
                  'Home',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DataScreen()));
                },
                leading: const Icon(Icons.create),
                title: const Text(
                  'Create Orders',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const History()));
                },
                leading: const Icon(Icons.bookmark_added_outlined),
                title: const Text(
                  'Orders History',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const Spacer(),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: const Text(
                    'Terms of Service | Privacy Policy',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF00E4FD),
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                _advancedDrawerController.showDrawer();
                // Navigator.pop(context);
              },
              icon: const Icon(Icons.menu)),
          title: const Text("Home"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                child: LayoutBuilder(
                  builder: (context, dimens) {
                    if (dimens.maxWidth <= kMobileBreakpoint) {
                      return customGridView(
                        columnRatio: 6,
                      );
                    } else if (dimens.maxWidth > kMobileBreakpoint && dimens.maxWidth <= kTabletBreakpoint) {
                      return customGridView(
                        columnRatio: 4,
                      );
                    } else if (dimens.maxWidth > kTabletBreakpoint && dimens.maxWidth <= kDesktopBreakPoint) {
                      return customGridView(
                        columnRatio: 3,
                      );
                    } else {
                      return customGridView(columnRatio: 2);
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
                        return Container(
                          color: Colors.transparent,
                        );
                      }
                      return snapshot.data!.docs.isNotEmpty
                          ? const CartWidget()
                          : Container(
                              color: Colors.transparent,
                            );
                    }),
              ),
            ],
          ),
        ),
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
                  addData(cartModel, ftProvider.getSelectedOption.toString());
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

  Widget customGridView({required int columnRatio}) {
    Random random = Random();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

          return StaggeredGridView.countBuilder(
            primary: false,
            crossAxisCount: 12,
            itemCount: cartModel.length,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6)],
                image: DecorationImage(
                    image: NetworkImage(
                      cartModel[index].image,
                    ),
                    fit: BoxFit.cover),
              ),
              height: random.nextInt(75).toDouble() + 200,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: InkWell(
                onTap: () {
                  showOption(cartModel[index]);
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage("assets/baghasht.jpeg"),
                          radius: 15,
                        ),
                        title: Text(
                          cartModel[index].name,
                        ),
                        subtitle: Text(
                          "Price ${cartModel[index].price}",
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            staggeredTileBuilder: (index) => StaggeredTile.fit(columnRatio),
          );
        }
      },
    );
  }
}
