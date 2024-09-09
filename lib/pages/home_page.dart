import 'package:ai_chat_app/components/input_widget.dart';
import 'package:ai_chat_app/components/message_widget.dart';
import 'package:ai_chat_app/const/api_key.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isTyping = false;
  final String _apiKey = apiKey;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add("You: ${_controller.text}");
      _messages.add("AI: Typing...");
      _isTyping = true;
    });

    final message = _controller.text;
    _controller.clear();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 64,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'text/plain',
        ),
      );

      final chatHistory = _messages
          .where((msg) => msg.startsWith("You: ") || msg.startsWith("AI: "))
          .map((msg) => Content.text(msg.substring(4)))
          .toList();

      final chat = model.startChat(
        history: chatHistory + [Content.text(message)],
      );

      final response = await chat.sendMessage(Content.text(message));

      setState(() {
        _messages.removeLast();
        _messages.add("AI: ${response.text}");
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add("Error: Failed to send message. $e");
        _isTyping = false;
      });
    }
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat App"),
        leading: IconButton(
          icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: widget.toggleTheme,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isAIMessage = _messages[index].startsWith("AI: ");
                return MessageWidget(
                  message: _messages[index],
                  isAIMessage: isAIMessage,
                );
              },
            ),
          ),
          InputWidget(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
