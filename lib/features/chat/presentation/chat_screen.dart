import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/chat_provider.dart';
import '../model/chat_messege.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';

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
  bool showScrollToBottom = false;

  late final AnimationController fabAnimationController;
  late final Animation<double> fabAnimation;

  final Map<int, GlobalKey> messageKeys = {};

  final List<String> availableModels = [
    "openai/gpt-4o-mini",
    "openai/gpt-4o",
    "openai/gpt-3.5-turbo",
    "google/gemini-1.5-flash",
  ];

  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();

    fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fabAnimation = CurvedAnimation(
      parent: fabAnimationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {    // First attempt
      scrollToBottom(animated: false);

      // Second attempt after a tiny delay to ensure layout is fully calculated
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) scrollToBottom(animated: false);
      });
    });
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      // Logic: If user is more than 100 pixels away from the bottom, show the FAB
      final bool isAtBottom = scrollController.offset >=
          scrollController.position.maxScrollExtent - 100;

      if (!isAtBottom) {
        if (!showScrollToBottom) {
          setState(() => showScrollToBottom = true);
          fabAnimationController.forward();
        }
      } else {
        if (showScrollToBottom) {
          setState(() => showScrollToBottom = false);
          fabAnimationController.reverse();
        }
      }
    });
  }

// Dynamic theme based on selected model
  Color _getModelColor(String model) {
    if (model.contains('4o-mini')) {
      return const Color(0xFF536DFE); // OpenAI Green
    }
    if (model.contains('4o')) {
      return const Color(0xFF8BC34A); // GPT-4o Lime
    }
    if (model.contains('3.5')) {
      return const Color(0xFF039BE5); // GPT-3.5 Blue
    }
    if (model.contains('1.5')) {
      return const Color(0xFFBCAAA4); // Gemini Teal
    }

    // Default fallback color to prevent the null error
    return Colors.deepPurpleAccent;
  }

  Future<void> toggleListening() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
            controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length));
          });
        });
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  bool get isNearBottom {
    if (!scrollController.hasClients) return true;
    return scrollController.offset >=
        scrollController.position.maxScrollExtent - 50;
  }

  void scrollToBottom({bool animated = false}) {
    if (!scrollController.hasClients) return;

    final double offset = scrollController.position.maxScrollExtent;

    if (animated) {
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // jumpTo is better for initial startup to avoid "flicker"
      scrollController.jumpTo(offset);
    }
  }

  Widget buildMessage(ChatMessage msg, int index, Color themeColor) {
    final key = messageKeys[index] ??= GlobalKey();
    final isUser = msg.isUser;
    final cleanText = msg.text.replaceAll(RegExp(r'\n?\*{3,}\n?'), '\n\n');

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: themeColor.withOpacity(0.1),
              child: Icon(Icons.auto_awesome, color: themeColor, size: 18),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? themeColor : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 16),
                ),
              ),
              child: MarkdownBody(
                data: cleanText,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  code: TextStyle(
                    backgroundColor:
                    isUser ? Colors.black26 : Colors.grey.shade300,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: isUser ? 0.25 : -0.25, curve: Curves.easeOut)
                .scale(begin: const Offset(0.95, 0.95)),
          ),

          if (isUser) const SizedBox(width: 8),

          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    )
    // 🔥 Animate entire message entry (main effect)
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    // Auto-scroll for new messages incoming
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only auto-scroll if we are already near the bottom OR if it's the very first load
      if (isNearBottom && !isTyping) {
        // Use a slight delay or ensure layout is done
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      }
    });

    final selectedModel = ref.watch(selectedModelProvider);
    final messages = ref.watch(chatProvider);
    final themeColor = _getModelColor(selectedModel);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AI Assistant", style: TextStyle(color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
            Text(selectedModel,
                style: TextStyle(color: themeColor, fontSize: 11)),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: availableModels.contains(selectedModel)
                ? selectedModel
                : null,
            underline: const SizedBox(),
            icon: Icon(Icons.settings_input_component, color: themeColor),
            items: availableModels.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Text(model, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) ref
                  .read(selectedModelProvider.notifier)
                  .setModel(value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            onPressed: _showClearDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (_, index) {
                if (index >= messages.length)
                  return _typingIndicator(themeColor);
                return buildMessage(messages[index], index, themeColor);
              },
            ),
          ),
          _buildInputSection(themeColor),
        ],
      ),
      floatingActionButton: FadeTransition(
        opacity: fabAnimation,
        child: showScrollToBottom
            ? FloatingActionButton.small(
          backgroundColor: themeColor,
          onPressed: () => scrollToBottom(animated: true),
          child: const Icon(Icons.arrow_downward, color: Colors.white),
        )
            : null,
      ),
    );
  }

  void _showClearDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text("Clear Chat?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                      "Clear", style: TextStyle(color: Colors.red))),
            ],
          ),
    );
    if (confirm == true) ref.read(chatProvider.notifier).clearChats();
  }

  Widget _buildInputSection(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(isListening ? Icons.mic : Icons.mic_none,
                  color: isListening ? Colors.red : themeColor),
              onPressed: toggleListening,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: isListening ? "Listening..." : "Message...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              backgroundColor: themeColor,
              child: IconButton(
                icon: const Icon(
                    Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty || isTyping) return;
                  controller.clear();
                  setState(() => isTyping = true);
                  await ref.read(chatProvider.notifier).sendMessage(text);
                  setState(() => isTyping = false);
                  scrollToBottom(animated: true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingIndicator(Color color) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          DotIndicator(color: color),
          const SizedBox(width: 4),
          DotIndicator(color: color),
          const SizedBox(width: 4),
          DotIndicator(color: color),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    fabAnimationController.dispose();
    controller.dispose();
    super.dispose();
  }
}

class DotIndicator extends StatefulWidget {
  final Color color;

  const DotIndicator({super.key, required this.color});

  @override
  State<DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
            color: widget.color.withOpacity(0.6), shape: BoxShape.circle),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}