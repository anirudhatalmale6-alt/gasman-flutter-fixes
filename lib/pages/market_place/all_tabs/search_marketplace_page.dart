import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/item_details_page.dart';

import '../market_place_service.dart';
import '../models/market_place_listing.dart';

class SearchMarketplacePage extends StatefulWidget {
  @override
  State<SearchMarketplacePage> createState() => _SearchMarketplacePageState();
}

class _SearchMarketplacePageState extends State<SearchMarketplacePage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Marketplace"),
      ),
      body: Column(
        children: [
          // 🔍 Search Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search here......",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // 📃 Results
          Expanded(
            child: searchText.isEmpty
                ? const Center(child: Text("Start typing to search"))
                : StreamBuilder<List<MarketplaceListing>>(
                    stream: MarketplaceService.instance.watchActiveListings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No results found"));
                      }
                      final docs = snapshot.data!.where((doc) {
                        final title = doc.title.toString().toLowerCase();
                        final description =
                            doc.description.toString().toLowerCase();

                        return title.contains(searchText) ||
                            description.contains(searchText);
                      }).toList();
                      if (docs.isEmpty) {
                        return const Center(child: Text("No results found"));
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index];

                          //  print("DDDD => ${jsonEncode(data)}");
                          List<dynamic> images = data.imageUrls;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return ItemDetailPage(listing: data);
                                }));
                              },
                              leading: Image.network(
                                images.first,
                                height: 50,
                                width: 50,
                              ),
                              title: Text(data.title),
                              subtitle: Text(
                                data.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
