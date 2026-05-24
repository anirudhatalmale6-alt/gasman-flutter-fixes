import 'package:flutter/material.dart';

import '../market_place_home_page.dart';
import '../market_place_service.dart';
import '../models/chat_conversion.dart';
import '../models/chat_messages.dart';


class ChatRoomPage extends StatefulWidget {
  final ChatConversation conversation;

  const ChatRoomPage({super.key, required this.conversation});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _msg = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.listingTitle),
        backgroundColor: kAppGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: MarketplaceService.instance
                  .watchMessages(widget.conversation.id),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    final isMe =
                        m.senderId == MarketplaceService.instance.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: isMe ? kAppGreen : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          m.text,
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msg,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: kAppGreen),
                onPressed: () async {
                  if (_msg.text.trim().isEmpty) return;

                  await MarketplaceService.instance.sendMessage(
                    conversation: widget.conversation,
                    text: _msg.text.trim(),
                  );

                  _msg.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

