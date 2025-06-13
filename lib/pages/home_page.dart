import 'package:ai_chat_app/components/input_widget.dart';
import 'package:ai_chat_app/components/message_widget.dart';
import 'package:ai_chat_app/const/api_key.dart';
import 'package:ai_chat_app/const/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isTyping = false;
  String? _apiKey;
  late AnimationController _alertAnimationController;
  bool _showingAlert = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _alertAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('apiKey');
    });
  }

  Future<void> _saveApiKey(String key) async {
    try {
      if (key.trim().isEmpty) {
        DelightToastBar(
          builder: (context) => const Card(
            child: ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text(
                "API key cannot be empty",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ).show(context);
        return;
      }

      if (key.length < 30) {
        DelightToastBar(
          builder: (context) => const Card(
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text(
                "API key seems too short. Please verify your key",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ).show(context);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiKey', key);
      setState(() {
        _apiKey = key;
      });

      DelightToastBar(
        builder: (context) => const Card(
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text(
              "API key saved successfully",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ).show(context);
    } catch (e) {
      DelightToastBar(
        builder: (context) => Card(
          child: ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(
              "Failed to save API key: $e",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ).show(context);
    }
  }

  Future<void> _deleteApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('apiKey');
      setState(() {
        _apiKey = null;
      });

      DelightToastBar(
        builder: (context) => const Card(
          child: ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              "API key deleted successfully",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ).show(context);
    } catch (e) {
      DelightToastBar(
        builder: (context) => Card(
          child: ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(
              "Failed to delete API key: $e",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ).show(context);
    }
  }

  void _showApiKeyDialog() {
    final TextEditingController controller =
        TextEditingController(text: _apiKey);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.key, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Manage API Key'),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(minWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your Gemini API key below:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter API Key',
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor:
                        theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your API key is stored securely on your device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
            if (_apiKey != null)
              TextButton.icon(
                onPressed: () {
                  _deleteApiKey();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            FilledButton.icon(
              onPressed: () {
                if (controller.text.isEmpty) {
                  DelightToastBar(
                    builder: (context) => const Card(
                      child: ListTile(
                        leading: Icon(Icons.error, color: Colors.red),
                        title: Text(
                          "Please enter an API key",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ).show(context);
                  return;
                }
                _saveApiKey(controller.text);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showApiKeyAlert() {
    if (_showingAlert) return;
    _showingAlert = true;

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final theme = Theme.of(context);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.key,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Title with slide animation
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Text(
                      'API Key Required',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message with fade animation
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.4, 1, curve: Curves.easeOut),
                      ),
                    ),
                    child: Text(
                      'Please set up your API key to start chatting with AI',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons with slide animation
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.6, 1, curve: Curves.easeOut),
                    )),
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showingAlert = false;
                          _showApiKeyDialog();
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.vpn_key, size: 18),
                        label: const Text('Set up now'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

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
        apiKey: _apiKey ?? apiKey,
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

      if (e.toString().contains("API key not valid")) {
        _showApiKeyAlert();
      }
    }
  }

  void _startNewChat() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            const Text('Clear Chat'),
          ],
        ),
        content: const Text(
            'Are you sure you want to clear the current chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat App"),
        leading: IconButton(
          icon: SvgPicture.asset(
            widget.isDarkMode ? AssetsIcons.moon : AssetsIcons.sun,
            // color: Colors.black,
          ),
          onPressed: widget.toggleTheme,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AssetsIcons.newChat,
            ),
            onPressed: _startNewChat,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showApiKeyDialog,
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
