import 'package:flutter/material.dart';
import 'dart:convert';
import 'main.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedVariationIndex = 0; // Track the selected variation index
  int selectedColorIndex = -1;
  late List<ProductPropertyAndValue> availableProperties;

  late Map<String, List<String>> availableValues;

  int selectedSizeIndex = -1;
  int selectedMaterialIndex = -1;
  @override
  void initState() {
    super.initState();

    print('Product Name: ${widget.product.name}');
    print('Brand Name: ${widget.product.brandName}');
    print('Image Path: ${widget.product.imagepath}');
    print('Description: ${widget.product.description}');
    print('Variations: ${widget.product.variations}');
    print('Available Properties: ${widget.product.availableProperties}');
    print('-------------------------');

    availableProperties = getAvailableProperties();
    availableValues = getAvailableValues();
  }

  List<ProductPropertyAndValue> getAvailableProperties() {
    List<ProductPropertyAndValue> properties = [];

    // widget.product.variations.forEach((variation) {
    widget.product.availableProperties.forEach((property) {
      // Check if the property already exists in the list
      bool exists = properties.any((existingProperty) =>
      existingProperty.property == property.property);

      // If it doesn't exist, add it to the list of available properties
      if (!exists) {
        properties.add(ProductPropertyAndValue(
          property: property.property,
          value: property.value,
        ));
      }
    }

    );

    return properties;
    //all the available properties of this product
  }

  Map<String, List<String>> getAvailableValues() {
    Map<String, List<String>> valuesMap = {};

    availableProperties.forEach((property) {
      valuesMap[property.property] = [];
    });

    // widget.product.variations.forEach((variation) {
    widget.product.availableProperties.forEach((property) {
      if (valuesMap.containsKey(property.property)) {
        if (!valuesMap[property.property]!.contains(property.value)&
            !valuesMap[property.property]!.contains(property.value.toUpperCase())) {
          valuesMap[property.property]!.add(property.value);
        }
      }
    });


    return valuesMap;
  }
  Color getColorFromHex(String colorHex) {
    String hex = colorHex.startsWith('#') ? colorHex : '0xFF$colorHex';
    return Color(int.parse(hex.replaceAll('#', '0x')));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Product details",
            style:
            TextStyle(fontSize: MediaQuery
                .of(context)
                .size
                .height * 0.03),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display product image and name
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.product.imagepath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight*0.02),
                  Text(widget.product.name, style: TextStyle(color: Colors.white, fontSize: screenHeight*0.03),),


                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight*0.02, top:screenHeight*0.02, left: screenHeight*0.01),
                    child: availableProperties.any((property) => property.property == 'Color')
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                      'Colors:', // Or use the appropriate label
                      style: TextStyle(fontSize: screenHeight*0.025, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < (availableValues['Color'] ?? []).length; i++)
                        // for (final colorHex in availableValues['Color'] ?? [])
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColorIndex = i; // Update selected index
                              });
                            },

                            child: Container(

                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getColorFromHex(availableValues['Color']?[i] ?? ''),
                                border: Border.all(
                                  color: selectedColorIndex == i ? Colors.green : Colors.grey, // Toggle border color
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    ]
                    ):SizedBox.shrink(),
                  ),

// Adding buttons for sizes
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight*0.02, top:screenHeight*0.02, left: screenHeight*0.01),
                    child: availableProperties.any((property) => property.property == 'Size')
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                      'Sizes:', // Or use the appropriate label
                      style: TextStyle(fontSize: screenHeight*0.025, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final size in availableValues['Size'] ?? [])
                          GestureDetector(
                            onTap: () {
                              // Handle size button tap
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(size, style: TextStyle(color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                    ]
                    ):SizedBox.shrink(),
                  ),


// Adding buttons for materials
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight*0.02, top:screenHeight*0.02, left: screenHeight*0.01),
                    child: availableProperties.any((property) => property.property == 'Materials')
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                      'Materials:', // Or use the appropriate label
                      style: TextStyle(fontSize: screenHeight*0.025, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,

                       children: [
                        for (final material in availableValues['Materials'] ??
                            [])
                          GestureDetector(
                            onTap: () {
                              // Handle material button tap
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(material, style: TextStyle(color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                    ]
                    ):SizedBox.shrink(),
                  )
                ]
            )
        )
    );
  }
}
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.product.name,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//             ),
//             // Display variations
//             SizedBox(
//               height: 100,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: widget.product.variations.length,
//                 itemBuilder: (context, index) {
//                   final variation = widget.product.variations[index];
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedVariationIndex = index;
//                       });
//                     },
//                     child: Container(
//                       margin: EdgeInsets.all(8),
//                       width: 80,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: selectedVariationIndex == index
//                               ? Colors.blue
//                               : Colors.grey,
//                         ),
//                       ),
//                       child: Center(child: Text('Variation $index')),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             // Display selected variation details
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Text(
//                     'Price: \$${widget.product.variations[selectedVariationIndex].price.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                   Text(
//                     'Quantity: ${widget.product.variations[selectedVariationIndex].quantity}',
//                     style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                   Text(
//                     'Colours: ${widget.product.variations[selectedVariationIndex].propertiesAndValues[0].value}',
//                     style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                 ],
//               ),
//
//             ),
//             // Display product properties
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Available Properties:',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   // Map through available properties and display them
//                   ...widget.product.availableProperties.map((property) {
//                     return Row(
//                       children: [
//                         Text('${property.property}: ',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text(property.value),
//                       ],
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
