import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton> {
  bool _isOpen = false;
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'agent',
      'text': 'Hello Kushal! 👋 Welcome to Takse Call support. How can we assist your call analytics setup today?',
      'time': 'Just now',
    }
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': 'Just now',
      });
      _msgController.clear();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'agent',
            'text': 'Thanks for reaching out! A support engineer is assigned to device KUS-3926-0820 and will assist you shortly.',
            'time': 'Just now',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen)
          Positioned(
            right: 0,
            bottom: 70,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              child: Container(
                width: 360,
                height: 480,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Chat Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Takse Call Live Support',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  'Online • Quick reply in 2 min',
                                  style: TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _isOpen = false),
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            splashRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    // Messages
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.all(12),
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isUser = msg['sender'] == 'user';
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                constraints: const BoxConstraints(maxWidth: 260),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: isUser ? null : Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['text']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isUser ? Colors.white : AppColors.textPrimary,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['time']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isUser ? Colors.white70 : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Input Bar
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: AppColors.border)),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // The Circular Blue Floating Button matching the screenshot
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _isOpen = !_isOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isOpen ? Icons.close_rounded : Icons.chat_bubble_rounded,
                    key: ValueKey(_isOpen),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
