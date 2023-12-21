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
  int selectedVariationIndex = 0;
  bool zero=false;// Track the selected variation index
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

  List<ProductVariation> getVariantsByColor(int colorIndex) {
    final selectedColor = availableValues['Color']?[colorIndex] ?? '';
    return widget.product.variations.where((variant) {
      return variant.propertiesAndValues.any((property) =>
      property.property.toLowerCase() == 'color' &&
          property.value.toLowerCase() == selectedColor.toLowerCase());
    }).toList();
  }
  int selectedImageIndex = 0;
  int selectedVariantImageIndex = 0;

  PageController _pageController = PageController(viewportFraction: 0.7);
  // int selectedImageIndex = 0; // Track the selected image index

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  // Horizontal scrollable container for variant images
                  Container(
                    height: screenHeight * 0.3,
                    width: screenWidth * 1,
                    child: PageView.builder(
                      itemCount: widget.product
                          .variations[selectedVariationIndex].productVarientImages.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = widget.product
                            .variations[selectedVariationIndex].productVarientImages[index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0;
                      i <
                          widget.product
                              .variations[selectedVariationIndex]
                              .productVarientImages.length;
                      i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImageIndex = i;
                              _pageController.animateToPage(
                                selectedImageIndex,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(8),
                            width: screenWidth *
                                0.1, // Adjust the width as needed
                            height: screenHeight *
                                0.08, // Adjust the height as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedImageIndex == i
                                    ? Colors.lightGreenAccent.shade700
                                    : Colors.transparent, // Toggle border color
                                width: 2.0,
                              ),
                            ),
                            child: Image.network(
                              widget.product.variations[selectedVariationIndex]
                                  .productVarientImages[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: screenHeight*0.02),
                  Text(widget.product.name, style: TextStyle( color: Colors.grey.shade200, fontSize: screenHeight*0.03),),
                  SizedBox(height: screenHeight*0.017),
                  Text(
                    'EGP ${widget.product.variations[selectedVariationIndex].price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: screenHeight*0.023,
                      color: Colors.grey.shade400,
                    ),
                  ),


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
                                      selectedColorIndex = i;
                                      final variants = getVariantsByColor(selectedColorIndex);
                                      if (variants.isNotEmpty) {
                                        // Update selected variation index based on the filtered variants
                                        selectedVariationIndex = widget.product.variations.indexOf(variants[0]);
                                      }
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

                  if (!availableValues.containsKey('Color'))
                  // Showing the price and quantity for the selected size
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02, top: screenHeight * 0.02, left: screenHeight * 0.01),
                      child: availableProperties.any((property) => property.property == 'Size')
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sizes:', // Or use the appropriate label
                            style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < (availableValues['Size'] ?? []).length; i++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSizeIndex = i;

                                      final selectedSize = availableValues['Size']?[selectedSizeIndex] ?? '';

                                      final variant = widget.product.variations.firstWhere((variant) =>
                                          variant.propertiesAndValues.any((property) =>
                                          property.property.toLowerCase() == 'size' &&
                                              property.value.toLowerCase() == selectedSize.toLowerCase()),
                                      );

                                      if (variant != null) {
                                        selectedVariationIndex = widget.product.variations.indexOf(variant);
                                        zero = false;
                                      } else {
                                        selectedVariationIndex = -1;
                                        zero = true;
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: selectedSizeIndex == i ? Colors.lightGreenAccent.shade700 : null,
                                      border: Border.all(
                                        color: selectedSizeIndex == i ? Colors.lightGreenAccent.shade700 : Colors.grey,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text((availableValues['Size'] ?? [])[i], style: TextStyle(
                                      color: selectedSizeIndex == i ? Colors.black : Colors.white,)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      )
                          : SizedBox.shrink(),
                    ),

                  if (availableValues.containsKey('Color'))
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02, top: screenHeight * 0.02, left: screenHeight * 0.01),
                      child: availableProperties.any((property) => property.property == 'Size')
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sizes:', // Or use the appropriate label
                            style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < (availableValues['Size'] ?? []).length; i++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSizeIndex = i;

                                      // Find the variant that matches selected color and size
                                      final selectedColor = availableValues['Color']?[selectedColorIndex] ?? '';
                                      final selectedSize = availableValues['Size']?[selectedSizeIndex] ?? '';

                                      final variant = widget.product.variations.firstWhere((variant) =>
                                      variant.propertiesAndValues.any((property) =>
                                      property.property.toLowerCase() == 'color' &&
                                          property.value.toLowerCase() == selectedColor.toLowerCase()) &&
                                          variant.propertiesAndValues.any((property) =>
                                          property.property.toLowerCase() == 'size' &&
                                              property.value.toLowerCase() == selectedSize.toLowerCase()),
                                      );

                                      if (variant != null) {
                                        bool zero = false;
                                        selectedVariationIndex = widget.product.variations.indexOf(variant);
                                      } else {
                                        bool zero = true;
                                        // If no variant matches, set quantity to 0
                                        selectedVariationIndex = -1;
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: selectedSizeIndex == i ? Colors.lightGreenAccent.shade700 : null,
                                      border: Border.all(
                                        color: selectedSizeIndex == i ? Colors.lightGreenAccent.shade700 : Colors.grey,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text((availableValues['Size'] ?? [])[i], style: TextStyle(
                                        color: selectedSizeIndex == i ? Colors.black : Colors.white,fontSize: screenHeight*0.02)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      )
                          : SizedBox.shrink(),
                    ),



                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.02, top: screenHeight * 0.02, left: screenHeight * 0.01),
                    child: availableProperties.any((property) => property.property == 'Materials')
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Materials:', // Or use the appropriate label
                          style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final material in availableValues['Materials'] ?? [])
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMaterialIndex = availableValues['Materials']?.indexOf(material) ?? -1;

                                    if (!availableValues.containsKey('Color') && !availableValues.containsKey('Size')) {
                                      // Variant selection logic when Color and Size are not present
                                      final variant = widget.product.variations.firstWhere((variant) =>
                                          variant.propertiesAndValues.any((property) =>
                                          property.property.toLowerCase() == 'materials' &&
                                              property.value.toLowerCase() == material.toLowerCase()));

                                      if (variant != null) {
                                        selectedVariationIndex = widget.product.variations.indexOf(variant);
                                        zero = false;
                                      } else {
                                        selectedVariationIndex = -1;
                                        zero = true;
                                      }
                                    } else if (selectedColorIndex != -1 && selectedSizeIndex != -1) {
                                      // Variant selection logic when Color and Size are present
                                      final selectedColor = availableValues['Color']?[selectedColorIndex] ?? '';
                                      final selectedSize = availableValues['Size']?[selectedSizeIndex] ?? '';

                                      final variant = widget.product.variations.firstWhere((variant) =>
                                      variant.propertiesAndValues.any((property) =>
                                      property.property.toLowerCase() == 'color' &&
                                          property.value.toLowerCase() == selectedColor.toLowerCase()) &&
                                          variant.propertiesAndValues.any((property) =>
                                          property.property.toLowerCase() == 'size' &&
                                              property.value.toLowerCase() == selectedSize.toLowerCase()) &&
                                          variant.propertiesAndValues.any((property) =>
                                          property.property.toLowerCase() == 'materials' &&
                                              property.value.toLowerCase() == material.toLowerCase()));

                                      if (variant != null) {
                                        selectedVariationIndex = widget.product.variations.indexOf(variant);
                                        zero = false;
                                      } else {
                                        selectedVariationIndex = -1;
                                        zero = true;
                                      }
                                    }
                                  });
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
                                    color: selectedMaterialIndex == availableValues['Materials']?.indexOf(material)
                                        ? Colors.lightGreenAccent.shade700// Change the button color when selected
                                        : null,
                                  ),
                                  child: Text(material, style: TextStyle(
                                      color: selectedMaterialIndex == availableValues['Materials']?.indexOf(material)
                                          ? Colors.black// Change the button color when selected
                                          : Colors.white,fontSize: screenHeight*0.02)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    )
                        : SizedBox.shrink(),
                  ),

                  zero ?
                  Text(
                    'Quantity: 0',
                    style: TextStyle(
                      fontSize: screenHeight*0.023,
                      color: Colors.grey.shade400,
                    ),
                  ):
                  Text(
                    'Quantity: ${widget.product.variations[selectedVariationIndex].quantity}',
                    style: TextStyle(
                      fontSize: screenHeight*0.023,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  Padding(
                    padding:  EdgeInsets.only(top:screenHeight*0.05),
                    child: Center(
                      child: Container(
                        width: screenWidth*0.9,
                        height: screenHeight*0.07,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenWidth*0.1), // Adjust the value as needed
                          color: Colors.grey.shade700, // Background color for the collapsed state

                        ),// Background color for the collapsed state
                        child: ExpansionTile(
                          title: Text(
                            'Description',
                            style: TextStyle(color: Colors.grey.shade300, fontSize: screenHeight*0.025),
                          ),
                          backgroundColor: Colors.black12, // Background color for the expanded state
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                widget.product.description,
                                style: TextStyle(color: Colors.grey.shade300, fontSize: screenHeight*0.02),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  // Text("Description: ${widget.product.description}", style: TextStyle(color: Colors.white)),
                ]
            )
        )
    );
  }
}

