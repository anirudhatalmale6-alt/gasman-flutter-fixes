import 'package:flutter/material.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/market_place_listing.dart';


class AdminReviewPage extends StatelessWidget {
  const AdminReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Listings"),
        backgroundColor: kAppGreen,
      ),
      body: StreamBuilder<List<MarketplaceListing>>(
        stream: MarketplaceService.instance.watchPendingListingsForAdmin(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text("No pending listings"));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final listing = items[i];
              return ListTile(
                leading: listing.imageUrls.isEmpty
                    ? const Icon(Icons.image)
                    : Image.network(listing.imageUrls.first, width: 60),
                title: Text(listing.title),
                subtitle: Text("Seller: ${listing.sellerName}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        MarketplaceService.instance.adminApproveListing(listing.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        MarketplaceService.instance.adminRejectListing(listing.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
