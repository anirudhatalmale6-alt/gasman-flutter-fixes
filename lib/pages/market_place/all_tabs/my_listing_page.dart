import 'package:flutter/material.dart';
import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/market_place_listing.dart';
import 'item_details_page.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        backgroundColor: kAppGreen,
      ),
      body: StreamBuilder<List<MarketplaceListing>>(
        stream: MarketplaceService.instance.watchMyListings(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final listings = snap.data!;
          if (listings.isEmpty) {
            return const Center(child: Text("You have no listings yet"));
          }

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (_, i) {
              final listing = listings[i];

              return ListTile(
                leading: listing.imageUrls.isNotEmpty
                    ? Image.network(listing.imageUrls.first, width: 60)
                    : const Icon(Icons.image),
                title: Text(listing.title),
                subtitle: Text("£${listing.price.toStringAsFixed(2)}"),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: "delete",
                      child: const Text("Delete"),
                      onTap: () {
                        MarketplaceService.instance.deleteProduct(listing.id);
                      },
                    ),
                  ],
                  onSelected: (value) {
                    if (value == "delete") {
                      MarketplaceService.instance.deleteProduct(listing.id);
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemDetailPage(listing: listing),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
