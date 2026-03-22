

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/chat_provider.dart';
import '../model/chat_messege.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isTyping = false;

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildMessage(ChatMessage msg) {
    final isUser = msg.isUser;
    final avatar = isUser ? Icons.person : Icons.smart_toy;

    // Remove horizontal rules (***)
    final cleanText = msg.text.replaceAll(RegExp(r'\n?\*{3,}\n?'), '\n\n');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) CircleAvatar(child: Icon(avatar)),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: cleanText, // Pass the cleaned text
                styleSheet: MarkdownStyleSheet(
                  h3: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  p: TextStyle(
                    color: Colors.black87,
                  ),
                  listBullet: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) CircleAvatar(child: Icon(avatar)),
        ],
      ),
    );
  }

  Widget typingIndicator() {
    return Row(
      children: [
        const CircleAvatar(child: Icon(Icons.smart_toy)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              DotIndicator(),
              SizedBox(width: 2),
              DotIndicator(),
              SizedBox(width: 2),
              DotIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    // Scroll to bottom after messages update
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear Chat"),
                  content:
                  const Text("Are you sure you want to delete all chats?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(chatProvider.notifier).clearChats();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index >= messages.length) return typingIndicator();
                  final msg = messages[index];
                  return buildMessage(msg);
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;

                    controller.clear();
                    setState(() => isTyping = true);

                    await ref.read(chatProvider.notifier).sendMessage(text);

                    setState(() => isTyping = false);
                    scrollToBottom();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DotIndicator extends StatefulWidget {
  const DotIndicator({super.key});
  @override
  _DotIndicatorState createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}