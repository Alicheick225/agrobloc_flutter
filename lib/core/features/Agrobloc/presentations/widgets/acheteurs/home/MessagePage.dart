import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/MessagingService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/MessageModel.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;   // utilisateur connecté
  final String receiverId;      // utilisateur avec qui on discute

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _messagingService.getMessages(
        widget.currentUserId,
        widget.receiverId,
      );
      setState(() {
        _messages = messages;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print("❌ Erreur chargement messages: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.currentUserId,
      receiverId: widget.receiverId,
      content: _controller.text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage); // ajout direct pour réactivité
      _controller.clear();
    });

    try {
      await _messagingService.sendMessage(newMessage);
    } catch (e) {
      print("❌ Erreur envoi message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messagerie")),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true, // dernier message en bas
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[_messages.length - 1 - i];
                      final isMe = msg.senderId == widget.currentUserId;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg.content),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Écrire un message...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
