import 'package:flutter/material.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/market_place_listing.dart';
import 'item_details_page.dart' hide kAppGreen;
import 'search_marketplace_page.dart';


class BrowseItemsPage extends StatelessWidget {
  const BrowseItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Items"),
        backgroundColor: kAppGreen,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchMarketplacePage()),
            );

          }, icon: Icon(Icons.search))
        ],
      ),
      body: StreamBuilder<List<MarketplaceListing>>(
        stream: MarketplaceService.instance.watchActiveListings(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No items currently available."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return _ListingCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final MarketplaceListing item;

  const _ListingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailPage(listing: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Expanded(
              child: item.imageUrls.isNotEmpty
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  item.imageUrls.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : const Icon(Icons.image_outlined, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("£${item.price.toStringAsFixed(2)}"),
                  Text(item.locationPostcode, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

