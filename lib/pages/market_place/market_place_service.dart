import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/main.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import 'models/chat_conversion.dart';
import 'models/chat_messages.dart';
import 'models/market_place_listing.dart';
import 'models/market_place_order.dart';

class MarketplaceService {
  MarketplaceService._();

  static final MarketplaceService instance = MarketplaceService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _functions = FirebaseFunctions.instance;

  // ---------- Helpers ----------

  String get uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in');
    }
    return user.uid;
  }

  User? get authUser {
    final user = _auth.currentUser;
    return user;
  }

  String get displayName {
    final user = _auth.currentUser;
    return user?.displayName ?? 'Gas Man User';
  }

  // ============================================================
  // LISTINGS
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _listingsRef =>
      _firestore.collection('marketplace_listings');

  /// Uploads all images to Storage and returns list of URLs.
  Future<List<String>> uploadListingImages(
    List<File> files, {
    required String listingId,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage
          .ref()
          .child('marketplace_images')
          .child(listingId)
          .child(fileName);

      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// Creates a new listing.
  Future<String> createListing(MarketplaceListing listing) async {
    final doc = _listingsRef.doc();

    final data = listing.copyWith(
      id: doc.id,
      sellerId: uid,
      sellerName: displayName,
      createdAt: DateTime.now(),
      isActive: true,
      approved: true, // require admin approval
    );

    await doc.set(data.toMap());
    return doc.id;
  }

  /// Update listing (only owner or admin).
  Future<void> updateListing(MarketplaceListing listing) async {
    await _listingsRef.doc(listing.id).update(listing.toMap());
  }

  /// Soft delete listing (set inactive).
  Future<void> deleteListing(String listingId) async {
    await _listingsRef.doc(listingId).delete();
  }

  Future<void> deleteProduct(String docId) async {
    try {
      Utils.showLoading(message: "Please wait...", dismissible: false);
      final _docRef = _listingsRef.doc(docId);

      final snapshot = await _docRef.get();

      if (!snapshot.exists) {
       // print("Document not found");
        Utils.hideLoading();
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;

      /// 2️⃣ GET IMAGE LIST
      List<dynamic> images = data['imageUrls'] ?? [];

      /// 3️⃣ DELETE EACH IMAGE FROM FIREBASE STORAGE
      for (var url in images) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        //  print("Deleted image: $url");
        } catch (e) {
          Utils.hideLoading();
          print("Error deleting image: $e");
        }
      }

      /// 4️⃣ DELETE FIRESTORE DOCUMENT
      await _docRef.delete();

     // print("Document deleted successfully");
    } catch (e) {
      Utils.hideLoading();
     // print("Delete error: $e");
    }
  }

  /// Public browse stream: only active & approved.
  Stream<List<MarketplaceListing>> watchActiveListings() {
    return _listingsRef
        .where('isActive', isEqualTo: true)
        .where('approved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MarketplaceListing.fromMap(d.id, d.data()))
            .toList());
  }

  /// My listings (for seller).
  Stream<List<MarketplaceListing>> watchMyListings() {
    //print("Seller Id $uid");
    return _listingsRef
        .where('sellerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MarketplaceListing.fromMap(d.id, d.data()))
            .toList());
  }

  /// Admin – listings waiting for approval.
  Stream<List<MarketplaceListing>> watchPendingListingsForAdmin() {
    return _listingsRef
        .where('approved', isEqualTo: false)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MarketplaceListing.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> adminApproveListing(String listingId) async {
    await _listingsRef.doc(listingId).update({'approved': true});
  }

  Future<void> adminRejectListing(String listingId) async {
    await _listingsRef.doc(listingId).update({
      'isActive': false,
      'approved': false,
    });
  }

  // ============================================================
  // SAVED ITEMS
  // ============================================================

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(uid);

  Future<void> toggleSavedListing({
    required String listingId,
    required bool currentlySaved,
    required Function onSucces,
  }) async {
    try {
      Utils.showLoading();
      await _userDoc.update({
        'savedListingIds': currentlySaved
            ? FieldValue.arrayRemove([listingId])
            : FieldValue.arrayUnion([listingId]),
      });

      ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
        SnackBar(
            content: Text(currentlySaved
                ? "Removed from list"
                : "Saved to list successfully")),
      );
      onSucces();
      Utils.hideLoading();
    } on Exception catch (e) {
      // TODO
      Utils.hideLoading();
    }
  }

  Stream<List<MarketplaceListing>> watchSavedListings() async* {
    await for (final userSnap in _userDoc.snapshots()) {
      final ids =
          List<String>.from(userSnap.data()?['savedListingIds'] ?? const []);
      if (ids.isEmpty) {
        yield const <MarketplaceListing>[];
        continue;
      }

      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, (i + 10).clamp(0, ids.length)));
      }

      final results = <MarketplaceListing>[];
      for (final chunk in chunks) {
        final snap = await _listingsRef
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        results.addAll(
            snap.docs.map((d) => MarketplaceListing.fromMap(d.id, d.data())));
      }

      yield results;
    }
  }

  Future<List<String>> getSavedListings() async {
    final docsnap = await _userDoc.get();
    final ids =
        List<String>.from(docsnap.data()?['savedListingIds'] ?? const []);

    return ids;
  }

  // ============================================================
  // CHAT
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection('marketplace_conversations');

  Stream<List<ChatConversation>> watchMyConversations() {
    return _conversationsRef
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatConversation.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _conversationsRef
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }

  /// Get or create conversation between current user (buyer) and seller for listing.
  Future<ChatConversation> openOrCreateConversationForListing(
      MarketplaceListing listing) async {
    // buyer is current user
    final buyerId = uid;
    final buyerName = displayName;

    // 1. Try to find existing conv
    final existing = await _conversationsRef
        .where('listingId', isEqualTo: listing.id)
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      return ChatConversation.fromMap(doc.id, doc.data());
    }

    // 2. Create new conv
    final doc = _conversationsRef.doc();
    final now = DateTime.now();

    final data = ChatConversation(
      id: doc.id,
      listingId: listing.id,
      listingTitle: listing.title,
      buyerId: buyerId,
      buyerName: buyerName,
      sellerId: listing.sellerId,
      sellerName: listing.sellerName,
      updatedAt: now,
      lastMessagePreview: '',
    ).toMap()
      ..['participants'] = [buyerId, listing.sellerId];

    await doc.set(data);

    return ChatConversation.fromMap(doc.id, data);
  }

  Future<void> sendMessage({
    required ChatConversation conversation,
    required String text,
  }) async {
    final convRef = _conversationsRef.doc(conversation.id);
    final msgRef = convRef.collection('messages').doc();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _firestore.runTransaction((tx) async {
      tx.set(msgRef, {
        'conversationId': conversation.id,
        'senderId': uid,
        'senderName': displayName,
        'text': text,
        'sentAt': now,
      });

      tx.update(convRef, {
        'updatedAt': now,
        'lastMessagePreview': text,
      });
    });
  }

  // ============================================================
  // PAYPAL / ORDERS via Cloud Functions
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('marketplace_orders');

  Future<CreateOrderResult> createPaypalOrderForListing(
      MarketplaceListing listing) async {
    final callable = _functions.httpsCallable('createPaypalOrder');

    final result = await callable.call(<String, dynamic>{
      'listingId': listing.id,
    });

    final data = Map<String, dynamic>.from(result.data as Map);

    return CreateOrderResult(
      backendOrderId: data['backendOrderId'] as String,
      paypalOrderId: data['paypalOrderId'] as String,
      approvalUrl: data['approvalUrl'] as String,
    );
  }

  Future<String> capturePaypalOrder(String backendOrderId) async {
    final callable = _functions.httpsCallable('capturePaypalOrder');
    final result = await callable
        .call(<String, dynamic>{'backendOrderId': backendOrderId});
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['status'] as String; // e.g. COMPLETED
  }

  Stream<List<MarketplaceOrder>> watchMyOrders() {
    return _ordersRef
        .where('buyerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MarketplaceOrder.fromMap(d.id, d.data()))
            .toList());
  }

  loginUser(
      {required String email,
      required String password,
      required Function onSuccess,
      required Function onFailed}) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      onSuccess();
    } catch (e) {
      onFailed();
      ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {}
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required Function onSuccess,
    required Function onFailed,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2. Save extra user data in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
      onSuccess();
    } on FirebaseAuthException catch (e) {

      String message;
      if (e.code == 'email-already-in-use') {
        message = "The email address is already in use by another account.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      } else if (e.code == 'weak-password') {
        message = "The password is too weak.";
      } else {
        message = e.message ?? "Something went wrong";
      }

      ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
      onFailed();

    }catch (e) {
      onFailed();
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  static Future<bool> deleteMarketplaceListingWithImages({
    required String documentId,
    required List<String> imageUrls,
  }) async {
    try {
      // 1️⃣ Delete all images from Firebase Storage
      if (imageUrls.isNotEmpty) {
        await Future.wait(
          imageUrls.where((url) => url.isNotEmpty).map(
                (url) => FirebaseStorage.instance
                    .refFromURL(url)
                    .delete()
                    .catchError((e) {
                  // Prevent failure if one image is missing
                  print("Image delete failed: $e");
                }),
              ),
        );
      }

      // 2️⃣ Delete Firestore document
      await FirebaseFirestore.instance
          .collection('marketplace_listing')
          .doc(documentId)
          .delete();

      return true;
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.message}');
      return false;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  Future<void> deleteChat(String id) async {
    try {
      Utils.showLoading();
      await _conversationsRef.doc(id).delete();
      Utils.hideLoading();
    } on Exception catch (e) {
      // TODO
      Utils.hideLoading();
    }
  }
}

class CreateOrderResult {
  final String backendOrderId;
  final String paypalOrderId;
  final String approvalUrl;

  CreateOrderResult({
    required this.backendOrderId,
    required this.paypalOrderId,
    required this.approvalUrl,
  });
}
