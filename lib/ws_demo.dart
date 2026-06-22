import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsDemo extends StatefulWidget {
  const WsDemo({super.key});

  @override
  State<WsDemo> createState() => _WsDemoState();
}

class _WsDemoState extends State<WsDemo> {
  WebSocketChannel? _channel;
  final _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080'));

      _channel!.stream.listen(
        (message) {
          setState(() {
            _messages.add('Server: $message');
            _isConnected = true;
          });
        },
        onError: (e) {
          setState(() {
            _messages.add('Error: $e');
            _isConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _messages.add('Disconnected');
            _isConnected = false;
          });
        },
      );

      setState(() => _isConnected = true);
    } catch (e) {
      setState(() => _messages.add('Failed to connect: $e'));
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _channel == null || !_isConnected) return;

    _channel!.sink.add(text);
    setState(() => _messages.add('Me: $text'));
    _controller.clear();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket'),
        actions: [
          // Reconnect button
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _isConnected ? null : _connect,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => Text(_messages[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected ? _sendMessage : null,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 Uri.parse('ws://10.0.2.2:8080') // emulator
Uri.parse('ws://<ip_address>:8080') // real device
*/
