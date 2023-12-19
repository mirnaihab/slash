import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ProductDetailsPage.dart';

void main() {
  runApp(MyApp());
}

class Product {
  final int id;
  final String name;
  final String description;
  final int brandId;
  final String? brandName;
  final String? brandLogoUrl;
  final int rating;
  final String imagepath;
  final List<ProductVariation> variations;
  final List<ProductProperty> availableProperties;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.brandId,
    this.brandName,
    this.brandLogoUrl,
    required this.rating,
    required this.imagepath,
    required this.variations,
    required this.availableProperties,
  });
}

class ProductVariation {
  final int id;
  final int productId;
  final num price;
  final int quantity;
  final bool inStock;
  final List<String> productVarientImages;
  final List<ProductPropertyAndValue> productPropertiesValues;

  ProductVariation({
    required this.id,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.inStock,
    required this.productVarientImages,
    required this.productPropertiesValues,
  });
}

class ProductPropertyAndValue {
  final String property;
  final String value;

  ProductPropertyAndValue({
    required this.property,
    required this.value,
  });
}

class ProductProperty {
  final String property;
  final String value;

  ProductProperty({
    required this.property,
    required this.value,
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();

    productsFuture = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(
      'https://slash-backend.onrender.com/product',
    ));
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);

      print('Parsed Response: $parsedResponse'); // Debugging print

      if (parsedResponse['statusCode'] == 200) {
        final data = parsedResponse['data'] as List<dynamic>;
        print('Data Length: ${data.length}'); // Debugging print

        List<Product> products = data.map((productData) {
          List<ProductVariation> variations = [];
          List<ProductProperty> properties = [];

          if (productData['ProductVariations'] != null) {
            for (var variationData in productData['ProductVariations']) {
              List<String> varientImages = [];
              List<ProductPropertyAndValue> productPropertiesValues = [];

              if (variationData['ProductVarientImages'] != null) {
                for (var image in variationData['ProductVarientImages']) {
                  varientImages.add(image['image_path']);
                }
              }

              if (variationData['productPropertiesValues'] != null) {
                for (var prop in variationData['productPropertiesValues']) {
                  productPropertiesValues.add(
                    ProductPropertyAndValue(
                      property: prop['property'],
                      value: prop['value'],
                    ),
                  );
                }
              }

              variations.add(
                ProductVariation(
                  id: variationData['id'],
                  productId: variationData['product_id'],
                  price: variationData['price'],
                  quantity: variationData['quantity'],
                  inStock: variationData['is_default'],
                  productVarientImages: varientImages,
                  productPropertiesValues: productPropertiesValues,
                ),
              );
            }
          }

          if (productData['availableProperties'] != null) {
            for (var property in productData['availableProperties']) {
              properties.add(
                ProductProperty(
                  property: property['property'],
                  value: property['value'],
                ),
              );
            }
          }

          return Product(
            id: productData['id'],
            name: productData['name'],
            description: productData['description'],
            brandId: productData['brand_id'],
            brandName: productData['Brands']['brand_name'],
            brandLogoUrl: productData['Brands']['brand_logo_image_path'],
            rating: productData['product_rating'],
            imagepath: variations.isNotEmpty
                ? variations[0].productVarientImages.isNotEmpty
                    ? variations[0].productVarientImages[0]
                    : '' // Adjust this according to your data structure
                : '',
            // Adjust this according to your data structure
            variations: variations,
            availableProperties: properties,
          );
        }).toList();

        print('Products Length: ${products.length}'); // Debugging print

        products.forEach((product) {
          print('Product Name: ${product.name}');
          print('Brand Name: ${product.brandName}');
          print('Image Path: ${product.imagepath}');
          print('Variations: ${product.variations.length}');
          print('Available Properties: ${product.availableProperties.length}');
          print('-------------------------');
        });

        return products;
      }
    }
    // Return an empty list if something goes wrong
    return [];
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Slash.",
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.height * 0.05),
          ),
        ),
        body: FutureBuilder<List<Product>>(
          future: productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('Failed to fetch data'));
            } else {
              List<Product> products = snapshot.data!;
              return Padding(
                padding:  EdgeInsets.only(top:screenHeight*0.02),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Display 2 items per row
                    crossAxisSpacing: 10.0,
                    // mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8, // Example aspect ratio value
                    // If you want to fix the height instead of using aspect ratio, use `itemExtent`:
                    //  itemExtent: 200,
                  ),
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = products[index];
                    return GestureDetector(
                        onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(product: "ll"),
                        ),
                      );
                    },
                    child:
                      Container(
                        // height: screenHeight * 0.7,
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                height: screenHeight * 0.2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: NetworkImage(product.imagepath),
                                    fit: BoxFit.contain,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0),
                                      bottom: Radius.circular(25.0)),
                                ),
                              ),
                              // SizedBox(height: screenHeight*0.01),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.02,
                                      top: screenHeight * 0.01),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),

                                      Row(
                                        children: [
                                          Text(
                                            '\$${product.variations.first.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.04),
                                          IconButton(
                                            icon: Icon(
                                              Icons.favorite_border,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              // Add to cart functionality
                                            },
                                          ),

                                          IconButton(
                                            icon: Icon(
                                              Icons.shopping_cart,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              // Add to cart functionality
                                            },
                                          ),
                                        ],
                                      ),

                                      // Align(
                                      //   alignment: Alignment.centerRight,
                                      //   child:
                                      //   IconButton(
                                      //     icon: Icon(Icons.add_shopping_cart),
                                      //     onPressed: () {
                                      //       // Add to cart functionality
                                      //     },
                                      //   ),
                                    ],
                                  )
                              )
                            ]
                        )
                      )
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
