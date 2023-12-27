import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:express/Express/Config/ConstantColor.dart';
import 'package:express/Express/Config/ConstantSize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final picker = ImagePicker();
  String imageDownloadUrl = '';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var height = ConstantSize.height;
    var width = ConstantSize.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Item"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: height! * 0.1),
                height: height * 0.25,
                width: width! * 0.6,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.black12),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      getImage();
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: Colors.black12,
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.1),
                height: height * 0.07,
                child: TextButton(
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(ConstantColor.colorOrangeTiger)),
                  onPressed: () {
                    if (_nameController.text.isEmpty || _priceController.text.isEmpty || imageDownloadUrl.isEmpty) {
                      _showSnackBar(context);
                    } else {
                      addData(imageDownloadUrl, _nameController.text, _priceController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Center(
                    child: Text(
                      'Add Items',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.colorWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        uploadImage(File(pickedFile.path));
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  Future uploadImage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage.ref().child('images/${DateTime.now().toString()}');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => debugPrint('Image_uploaded'));
    imageDownloadUrl = await storageReference.getDownloadURL();
    debugPrint('Image URL: $imageDownloadUrl');
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please fill all the fields'),
        duration: const Duration(seconds: 2), // Duration for which SnackBar is visible
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> addData(String image, String name, String price) async {
    String id = firestore.collection('cart').doc().id;
    try {
      firestore.collection('cart').doc(id).set({
        'id': id,
        'image': image,
        'name': name,
        'price': price,
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}
