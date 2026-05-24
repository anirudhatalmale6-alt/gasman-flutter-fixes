import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/market_place_listing.dart';
import 'chat_room_page.dart';

class ItemDetailPage extends StatefulWidget {
  final MarketplaceListing listing;

  const ItemDetailPage({super.key, required this.listing});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {


  List<String>  savedIds =[];
  bool _isSaved = false;
  Future buyItNow(BuildContext context) async {
    final res =
        await MarketplaceService.instance.createPaypalOrderForListing(widget.listing);

    // Open PayPal checkout in browser
    launchUrl(Uri.parse(res.approvalUrl));

    // After user returns, capture payment
    final result = await MarketplaceService.instance
        .capturePaypalOrder(res.backendOrderId);

    if (result == "COMPLETED") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment completed")),
      );
    }
  }

  Future openChat(BuildContext context) async {
    final conv = await MarketplaceService.instance
        .openOrCreateConversationForListing(widget.listing);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(conversation: conv),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIds();

  }

  void getIds() async{
    savedIds = await MarketplaceService.instance.getSavedListings();
  //  print("IDDDD $savedIds");
    if(savedIds.contains(widget.listing.id)){
      _isSaved = true;
    }else{
      _isSaved = false;
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.title),
        backgroundColor: kAppGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              child: ImageSlider(
                imageUrls: widget.listing.imageUrls,
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.listing.title, style: const TextStyle(fontSize: 22)),
            Text("£${widget.listing.price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const Text("Description",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.listing.description),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kAppGreen),
                  onPressed: () => MarketplaceService.instance.toggleSavedListing(listingId: widget.listing.id, currentlySaved: _isSaved,onSucces: (){
                    _isSaved = !_isSaved;
                    setState(() {

                    });
                  }),
                  child:  Icon(_isSaved ? Icons.bookmark : Icons.bookmark_outline),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kAppGreen),
                  onPressed: () => openChat(context),
                  child: const Text("Message Seller"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => buyItNow(context),
                  child: const Text("Buy It Now (PayPal)"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const ImageSlider({super.key, required this.imageUrls});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 250,
      child: Stack(
        children: [

          /// IMAGE PAGE VIEW
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {

              if (widget.imageUrls.isEmpty) {
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(Icons.image)),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imageUrls[index],
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          /// IMAGE NUMBER INDICATOR
          if (widget.imageUrls.isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
