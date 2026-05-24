import 'package:flutter/material.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/market_place_listing.dart';
import 'item_details_page.dart';


class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Items"), backgroundColor: kAppGreen),
      body: StreamBuilder<List<MarketplaceListing>>(
        stream: MarketplaceService.instance.watchSavedListings(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No saved items"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];

              return ListTile(
                leading: item.imageUrls.isNotEmpty
                    ? Image.network(item.imageUrls.first, width: 60)
                    : const Icon(Icons.image),
                title: Text(item.title),
                subtitle: Text("£${item.price.toStringAsFixed(2)}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ItemDetailPage(listing: item)),
                  );
                },
                trailing: InkWell(
                  onTap: (){
                    MarketplaceService.instance.toggleSavedListing(listingId: item.id, currentlySaved: true, onSucces: (){
                      items.removeAt(i);
                      setState(() {
                        
                      });
                    });
                  },
                  child: Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
