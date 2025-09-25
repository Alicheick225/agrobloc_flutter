import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();

    // Connexion WebSocket au serveur (adresse locale)
    channel = WebSocketChannel.connect(
      Uri.parse("ws://10.0.2.2:8000/ws"), 
      // ⚠️ 10.0.2.2 = adresse spéciale pour parler à ton PC depuis l’émulateur Android
    );

    // Quand un nouveau message arrive → on l’ajoute à la liste
    channel.stream.listen((data) {
      setState(() {
        messages.add(data.toString());
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text); // envoie au serveur
      _controller.clear();
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mini Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: _controller),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
