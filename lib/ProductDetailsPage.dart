import 'package:flutter/material.dart';
import 'dart:convert';

class ProductDetailsPage extends StatefulWidget {
  final String product;
  // final Product product;

  ProductDetailsPage({required this.product});


  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    // Use the product data to display details
    // Access the properties and variations from the 'product' object

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Product details",
          style:
          TextStyle(fontSize: MediaQuery.of(context).size.height * 0.03),
        ),
      ),
      body: Center(
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Text(
        //       'Product Name: ${product.name}',
        //       style: TextStyle(fontSize: 20),
        //     ),
        //     // Display other product details here
        //   ],
        // ),
      ),
    );
  }

}




