import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For API Key security
import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini API
import 'package:supabase_flutter/supabase_flutter.dart'; // Database
import '../../../core/constant/app_colors.dart';
import '../../profile/widgets/subscription_screen.dart'; // For upgrading

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  // --- CONFIG ---
  // Load API Key safely from .env
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  late final GenerativeModel _model;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // --- LIMIT STATE ---
  int _remainingChats = 10;
  bool _isPro = false;
  bool _isLoadingLimit = true;

  // Suggestions for empty state
  final List<String> _suggestions = [
    "Explain Quantum Physics like I'm 5",
    "Create a study plan for Finals",
    "Summarize the key points of WW2",
    "Quiz me on Biology",
  ];

  @override
  void initState() {
    super.initState();

    // 1. Safety Check
    if (_apiKey.isEmpty) {
      debugPrint("ERROR: GEMINI_API_KEY is missing in .env file!");
    } else {
      // 2. Initialize Gemini with a "Persona"
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        // THIS IS THE BRAIN IMPLANT 👇
        systemInstruction: Content.system("""
          You are Mira AI, the intelligent study assistant inside the 'Mira' app (Mastering Information Retention App).
          Your goal is to help students learn faster and remember longer.

          The Mira app has these specific tools you can recommend to users:
          1. 🍅 Pomodoro Timer: For focused work with breaks.
          2. 🧠 Feynman Method: To learn by explaining concepts simply.
          3. 🃏 Flashcards: For active recall and testing memory.
          4. 📝 Blurting Method: To write down everything they remember to test knowledge gaps.
          5. 📊 Eisenhower Matrix: To prioritize urgent vs. important tasks.
          6. 🧠 Second Brain: To organize notes and digital knowledge.

          GUIDELINES:
          - If a user feels overwhelmed, suggest the Eisenhower Matrix.
          - If a user can't focus, suggest the Pomodoro Timer.
          - If a user wants to memorize terms, suggest Flashcards.
          - Keep answers concise, encouraging, and academic but friendly.
          - Never say "I am a large language model." Say "I am Mira AI."
        """),
      );
    }

    // 3. Check Limits
    _checkUserLimitStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- 1. SUPABASE LIMIT LOGIC ---
  Future<void> _checkUserLimitStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // A. Check Level (Pro vs Reguler)
      final levelData = await Supabase.instance.client
          .from('level')
          .select('status')
          .eq('id', user.id)
          .maybeSingle();

      // B. Check Counters
      final limitData = await Supabase.instance.client
          .from('limitation')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          final status = levelData?['status'] ?? 'Reguler';
          // Check if status is one of the premium types
          _isPro = status == 'Monthly Premium' || status == 'Yearly Premium';

          if (limitData != null) {
            // Check Date Reset
            final String lastDate = limitData['last_reset_date'] ?? "";
            final String today = DateTime.now().toIso8601String().split('T')[0];

            if (lastDate != today) {
              // It's a new day! Reset counter in DB
              _resetDailyLimit(user.id);
              _remainingChats = 10;
            } else {
              // Same day, calculate remaining
              int used = limitData['chatbot_counter'] ?? 0;
              _remainingChats = 10 - used;
            }
          }
          _isLoadingLimit = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking limits: $e");
      if (mounted) setState(() => _isLoadingLimit = false);
    }
  }

  Future<void> _resetDailyLimit(String userId) async {
    await Supabase.instance.client
        .from('limitation')
        .update({
          'chatbot_counter': 0,
          'last_reset_date': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> _incrementUsageCounter() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Get current count
      final data = await Supabase.instance.client
          .from('limitation')
          .select('chatbot_counter')
          .eq('id', user.id)
          .single();

      int current = data['chatbot_counter'] ?? 0;

      // 2. Update + 1
      await Supabase.instance.client
          .from('limitation')
          .update({'chatbot_counter': current + 1})
          .eq('id', user.id);

      // 3. Update Local State (only matters for free users)
      if (mounted && !_isPro) {
        setState(() {
          _remainingChats--;
        });
      }
    } catch (e) {
      debugPrint("Failed to increment counter: $e");
    }
  }

  // --- 2. SEND MESSAGE LOGIC ---
  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    // --- GATEKEEPER: CHECK LIMIT ---
    // If not Pro AND no chats remaining, block them.
    if (!_isPro && _remainingChats <= 0) {
      _showUpgradeDialog();
      return;
    }

    _textController.clear();
    FocusScope.of(context).unfocus();

    // 1. Add User Message to UI
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true; // Show loading animation
    });
    _scrollToBottom();

    try {
      // 2. Call Gemini API
      if (_apiKey.isEmpty) {
        throw Exception("API Key not found. Please check .env file.");
      }

      final content = [Content.text(text)];
      final response = await _model.generateContent(content);

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: response.text ?? "I couldn't generate a response.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();

        // 3. Increment DB Counter (Only if successful)
        await _incrementUsageCounter();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("AI Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Daily Limit Reached"),
        content: const Text(
          "You have used your 10 free chats for today.\n\nUpgrade to Pro for UNLIMITED AI access!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Wait for Tomorrow",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const SubscriptionScreen()),
              ).then((_) => _checkUserLimitStatus()); // Refresh on return
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Upgrade Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // LIMIT INDICATOR (Only for Free Users)
          if (!_isPro && !_isLoadingLimit)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: _remainingChats > 0
                  ? const Color(0xFFFFF7ED) // Light Orange
                  : const Color(0xFFFEF2F2), // Light Red
              child: Text(
                _remainingChats > 0
                    ? "$_remainingChats free messages left today"
                    : "Daily limit reached. Upgrade for unlimited.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: _remainingChats > 0
                      ? Colors.orange[800]
                      : Colors.red[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // CHAT AREA
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),

          // TYPING INDICATOR
          if (_isTyping) _buildTypingIndicator(),

          // INPUT FIELD
          _buildInputArea(),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textMain,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AI Assistant",
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isPro ? "Unlimited Access" : "Basic Plan",
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.textMuted,
          ),
          onPressed: () {
            setState(() => _messages.clear());
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.freeBorder, height: 1),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "How can I help you study?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ask me anything about your subjects or planning.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _suggestions.map((suggestion) {
                return ActionChip(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.freeBorder),
                  ),
                  label: Text(
                    suggestion,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () => _handleSubmitted(suggestion),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return ChatBubble(message: msg);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.freeBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(1),
                const SizedBox(width: 4),
                _dot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0 > 0.5 ? 1.0 : 0.3,
          child: const CircleAvatar(
            radius: 3,
            backgroundColor: AppColors.textMuted,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.textMuted,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: "Ask anything...",
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASS MODEL & WIDGET PENDUKUNG ---

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 14,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                border: isUser ? null : Border.all(color: AppColors.freeBorder),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textMain,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
