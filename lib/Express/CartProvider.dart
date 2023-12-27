import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {



  int selectedOption = 1;


  double totalPrice = 0.0;

  int get getSelectedOption=> selectedOption;

  double get getTotalPrice=> totalPrice;


  set setSelectedOption(int option) {
    selectedOption = option;
    notifyListeners();
  }

  set setTotalPrice(double price) {
    totalPrice = price;
    notifyListeners();
  }

}
