import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/market_place_listing.dart';

class SellItemPage extends StatefulWidget {
  const SellItemPage({super.key});

  @override
  State<SellItemPage> createState() => _SellItemPageState();
}

class _SellItemPageState extends State<SellItemPage> {
  final _form = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _part = TextEditingController();

  // final _barcode = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _shipping = TextEditingController();
  final _postcode = TextEditingController();
  List<File> photos = [];

  ListingCondition condition = ListingCondition.used;
  DeliveryOption delivery = DeliveryOption.both;
  final picker = ImagePicker();

  Future<void> pickImages() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      if (!photos.any((p) => p.path == file.path)) {
        photos.add(file);
      }
    });
  }

  Future<void> _pickFromGallery() async {
    final imgs = await picker.pickMultiImage();

    if (imgs.isEmpty) return;

    setState(() {
      for (var xFile in imgs) {
        final file = File(xFile.path);

        if (!photos.any((p) => p.path == file.path)) {
          photos.add(file);
        }
      }
    });
  }

  Future saveListing() async {
    Utils.showLoading();

    if (!_form.currentState!.validate()) return;

    final newListing = MarketplaceListing(
      id: "",
      // auto created in service
      title: _title.text,
      partNumber: _part.text,
      barcode: /* _barcode.text*/ "",
      description: _description.text,
      price: double.tryParse(_price.text) ?? 0,
      shippingPrice: double.tryParse(_shipping.text),
      paypalEnabled: true,
      condition: condition,
      deliveryOption: delivery,
      category: "General",
      sellerId: MarketplaceService.instance.uid,
      // filled by service
      sellerName: MarketplaceService.instance.displayName,
      locationPostcode: _postcode.text,
      imageUrls: const [],
      createdAt: DateTime.now(),
      isActive: true,
      approved: true,
    );

    // 1) Create listing doc
    String docId = await MarketplaceService.instance.createListing(newListing);

    // 2) Upload photos
    final listingId = docId;
    final urls = await MarketplaceService.instance
        .uploadListingImages(photos, listingId: listingId);

    // 3) Update listing with image URLs
    final updated = newListing.copyWith(imageUrls: urls, id: listingId);
    await MarketplaceService.instance.updateListing(updated);

    Utils.hideLoading();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell an Item"),
        backgroundColor: kAppGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              input("Title", _title),
              input("Part Number", _part),
              //  input("Barcode", _barcode),
              input("Description", _description, maxLines: 3),
              input("Price (£)", _price, type: TextInputType.number),
              input("Shipping (£)", _shipping, type: TextInputType.number),
              input("Postcode", _postcode),

              const SizedBox(height: 16),

              const Text("Item Condition"),
              DropdownButton<ListingCondition>(
                value: condition,
                items: ListingCondition.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(getListingConditionName(e)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => condition = v!),
              ),

              const SizedBox(height: 16),
              const Text("Delivery Option"),
              DropdownButton<DeliveryOption>(
                value: delivery,
                items: DeliveryOption.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => delivery = v!),
              ),

              const SizedBox(height: 20),
              const Text("Photos"),
              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...photos.map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            height: 100.0,
                            width: 100.0,
                            child: Stack(
                              children: [
                                Image.file(
                                  f,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      photos.remove(f);
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kAppGreen),
                onPressed: saveListing,
                child: const Text("List Item"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget input(String label, TextEditingController ctl,
      {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctl,
        maxLines: maxLines,
        keyboardType: type,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String getListingConditionName(ListingCondition listingCondition) {
    if (listingCondition.name == "newItem") {
      return "New Item";
    } else if (listingCondition.name == "used") {
      return "Used";
    } else {
      return "Refurbished";
    }
  }
}
