// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../provider/chat_provider.dart';
// import '../model/chat_messege.dart';
// import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController controller = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   bool isTyping = false;
//   bool showScrollToBottom = false;

//   late final AnimationController fabAnimationController;
//   late final Animation<double> fabAnimation;

//   final List<String> availableModels = [
//     "openai/gpt-4o-mini",
//     "openai/gpt-4o",
//     "openai/gpt-3.5-turbo",
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // FAB fade animation
//     fabAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     fabAnimation = CurvedAnimation(
//       parent: fabAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Scroll to bottom initially
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       scrollToBottom(animated: false);
//     });

//     scrollController.addListener(() {
//       if (!scrollController.hasClients) return;

//       final nearBottom = isNearBottom;
//       if (!nearBottom) {
//         if (!showScrollToBottom) {
//           setState(() => showScrollToBottom = true);
//           fabAnimationController.forward();
//         }
//       } else {
//         if (showScrollToBottom) {
//           setState(() => showScrollToBottom = false);
//           fabAnimationController.reverse();
//         }
//       }
//     });
//   }

//   bool get isNearBottom {
//     if (!scrollController.hasClients) return true;
//     return scrollController.offset >=
//         scrollController.position.maxScrollExtent - 50;
//   }

//   void scrollToBottom({bool animated = false}) {
//     if (!scrollController.hasClients) return;

//     // Add a small delay to ensure the last message is rendered
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final maxScroll = scrollController.position.maxScrollExtent;

//       if (animated) {
//         scrollController.animateTo(
//           maxScroll + 20, // extra padding to fully show last message
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       } else {
//         scrollController.jumpTo(maxScroll + 20); // jump to end
//       }
//     });
//   }

//   Widget buildMessage(ChatMessage msg) {
//     final isUser = msg.isUser;
//     final avatar = isUser ? Icons.person : Icons.smart_toy;
//     final cleanText = msg.text.replaceAll(RegExp(r'\n?\*{3,}\n?'), '\n\n');

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: [
//           if (!isUser) CircleAvatar(child: Icon(avatar)),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isUser ? Colors.blue : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 2,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: MarkdownBody(
//                 data: cleanText,
//                 styleSheet: MarkdownStyleSheet(
//                   h3: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                   p: const TextStyle(color: Colors.black87),
//                   listBullet: const TextStyle(color: Colors.black87),
//                 ),
//               ),
//             ),
//           ),
//           if (isUser) const SizedBox(width: 8),
//           if (isUser) CircleAvatar(child: Icon(avatar)),
//         ],
//       ),
//     );
//   }

//   Widget typingIndicator() {
//     return Row(
//       children: [
//         const CircleAvatar(child: Icon(Icons.smart_toy)),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               DotIndicator(),
//               SizedBox(width: 2),
//               DotIndicator(),
//               SizedBox(width: 2),
//               DotIndicator(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedModel = ref.watch(selectedModelProvider);
//     final messages = ref.watch(chatProvider);

//     // Auto-scroll for new messages
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (isNearBottom) scrollToBottom(animated: true);
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("AI Chat"),
//         actions: [
//           DropdownButton<String>(
//             value: availableModels.contains(selectedModel)
//                 ? selectedModel
//                 : null,
//             dropdownColor: Colors.white,
//             underline: const SizedBox(),
//             icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
//             items: availableModels.map((model) {
//               return DropdownMenuItem(
//                 value: model,
//                 child: Text(model, style: const TextStyle(color: Colors.black)),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 ref.read(selectedModelProvider.notifier).setModel(value);
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () async {
//               final confirm = await showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text("Clear Chat"),
//                   content: const Text(
//                     "Are you sure you want to delete all chats?",
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text("Cancel"),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text("Yes"),
//                     ),
//                   ],
//                 ),
//               );
//               if (confirm == true) {
//                 ref.read(chatProvider.notifier).clearChats();
//               }
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 controller: scrollController,
//                 itemCount: messages.length + (isTyping ? 1 : 0),
//                 itemBuilder: (_, index) {
//                   if (index >= messages.length) return typingIndicator();
//                   return buildMessage(messages[index]);
//                 },
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message...",
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () async {
//                     final text = controller.text.trim();
//                     if (text.isEmpty || isTyping) return;

//                     controller.clear();
//                     setState(() => isTyping = true);

//                     await ref.read(chatProvider.notifier).sendMessage(text);

//                     setState(() => isTyping = false);
//                     scrollToBottom(animated: true);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FadeTransition(
//         opacity: fabAnimation,
//         child: showScrollToBottom
//             ? FloatingActionButton(
//                 onPressed: () => scrollToBottom(animated: false),
//                 child: const Icon(Icons.arrow_downward),
//               )
//             : null,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     fabAnimationController.dispose();
//     controller.dispose();
//     super.dispose();
//   }
// }

// class DotIndicator extends StatefulWidget {
//   const DotIndicator({super.key});
//   @override
//   _DotIndicatorState createState() => _DotIndicatorState();
// }

// class _DotIndicatorState extends State<DotIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     )..repeat(reverse: true);

//     _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: Container(
//         width: 6,
//         height: 6,
//         decoration: const BoxDecoration(
//           color: Colors.grey,
//           shape: BoxShape.circle,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

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
  bool showScrollToBottom = false;

  late final AnimationController fabAnimationController;
  late final Animation<double> fabAnimation;

  // Store GlobalKeys for each message to measure its height
  final Map<int, GlobalKey> messageKeys = {};

  final List<String> availableModels = [
    "openai/gpt-4o-mini",
    "openai/gpt-4o",
    "openai/gpt-3.5-turbo",
  ];

  @override
  void initState() {
    super.initState();

    // FAB fade animation
    fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fabAnimation = CurvedAnimation(
      parent: fabAnimationController,
      curve: Curves.easeInOut,
    );

    // Scroll to bottom initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(animated: false);
    });

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      final nearBottom = isNearBottom;
      if (!nearBottom) {
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

  bool get isNearBottom {
    if (!scrollController.hasClients) return true;
    return scrollController.offset >=
        scrollController.position.maxScrollExtent - 50;
  }

  // Scroll to the end of the last message dynamically
  void scrollToBottom({bool animated = false}) {
    if (!scrollController.hasClients || messageKeys.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastIndex = messageKeys.keys.isNotEmpty
          ? messageKeys.keys.last
          : null;
      if (lastIndex == null) return;

      final key = messageKeys[lastIndex];
      if (key != null && key.currentContext != null) {
        final renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final messageHeight = renderBox.size.height;

        final target =
            scrollController.position.maxScrollExtent + messageHeight;

        if (animated) {
          scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(target);
        }
      }
    });
  }

  Widget buildMessage(ChatMessage msg, int index) {
    final key = messageKeys[index] ??= GlobalKey();
    final isUser = msg.isUser;
    final avatar = isUser ? Icons.person : Icons.smart_toy;
    final cleanText = msg.text.replaceAll(RegExp(r'\n?\*{3,}\n?'), '\n\n');

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) CircleAvatar(child: Icon(avatar)),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: cleanText,
                styleSheet: MarkdownStyleSheet(
                  h3: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  p: const TextStyle(color: Colors.black87),
                  listBullet: const TextStyle(color: Colors.black87),
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
    final selectedModel = ref.watch(selectedModelProvider);
    final messages = ref.watch(chatProvider);

    // Auto-scroll for new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isNearBottom) scrollToBottom(animated: true);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat"),
        actions: [
          DropdownButton<String>(
            value: availableModels.contains(selectedModel)
                ? selectedModel
                : null,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            items: availableModels.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Text(model, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(selectedModelProvider.notifier).setModel(value);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear Chat"),
                  content: const Text(
                    "Are you sure you want to delete all chats?",
                  ),
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
          ),
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
                  return buildMessage(messages[index], index);
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
                    if (text.isEmpty || isTyping) return;

                    controller.clear();
                    setState(() => isTyping = true);

                    await ref.read(chatProvider.notifier).sendMessage(text);

                    setState(() => isTyping = false);
                    scrollToBottom(animated: true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FadeTransition(
        opacity: fabAnimation,
        child: showScrollToBottom
            ? FloatingActionButton(
                onPressed: () => scrollToBottom(animated: true),
                child: const Icon(Icons.arrow_downward),
              )
            : null,
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
