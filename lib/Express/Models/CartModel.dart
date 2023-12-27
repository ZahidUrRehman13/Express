class CartModel {
  String id;
  String image;
  String name;
  String price;
  String? status;
  int? counter;

  CartModel({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    this.status,
    this.counter,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'price': price,
      'status': status ?? '',
      'counter': counter ?? 1,
    };
  }


  // Create a factory constructor to deserialize JSON data back into an object
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      status: json['status'] ?? '',
      counter: json['counter'] ?? 1,
    );
  }


}
