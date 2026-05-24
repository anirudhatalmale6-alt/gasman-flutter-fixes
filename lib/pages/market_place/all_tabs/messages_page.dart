import 'dart:convert';

import 'package:flutter/material.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/chat_conversion.dart';
import 'chat_room_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages"), backgroundColor: kAppGreen),
      body: StreamBuilder<List<ChatConversation>>(
        stream: MarketplaceService.instance.watchMyConversations(),
        builder: (_, snap) {

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final convs = snap.data!;
          if (convs.isEmpty) {
            return const Center(child: Text("No messages yet"));
          }

          return ListView.builder(
            itemCount: convs.length,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (_, i) {
              final conv = convs[i];
              return Card(
                child: ListTile(
                  title: Text(conv.listingTitle),
                  subtitle: Text(conv.lastMessagePreview),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(conversation: conv),
                      ),
                    );
                  },
                  trailing: InkWell(
                    onTap: (){
                     showDeleteConversationDialog(context, (){
                       MarketplaceService.instance.deleteChat(conv.id);
                     });
                    },
                    child: Icon(Icons.delete),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> showDeleteConversationDialog(
      BuildContext context,
      VoidCallback onDelete,
      ) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TITLE
                  const Text(
                    "Delete Conversation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DESCRIPTION
                  const Text(
                    "Are you sure you want to delete this conversation? All messages will be permanently removed.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    children: [

                      /// CANCEL
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// DELETE
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Delete"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

