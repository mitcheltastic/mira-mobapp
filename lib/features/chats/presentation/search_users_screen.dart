import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  // 1. Optimistic Updates (Clicks right now)
  final Set<String> _pendingRequests = {};

  // 2. Database Status (Real status from DB)
  Map<String, String> _dbFriendStatus =
      {}; // Key: userId, Value: 'Friend' or 'Pending'

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _dbFriendStatus.clear(); // Reset status on new search
    });

    final myId = _supabase.auth.currentUser!.id;

    try {
      // --- STEP 1: FIND PEOPLE ---
      final data = await _supabase
          .from('profiles')
          .select()
          .or('full_name.ilike.%$query%,nickname.ilike.%$query%')
          .neq('id', myId)
          .limit(20);

      final List<Map<String, dynamic>> profiles =
          List<Map<String, dynamic>>.from(data);
      final Map<String, String> statusMap = {};

      // --- STEP 2: CHECK FRIENDSHIP STATUS ---
      if (profiles.isNotEmpty) {
        final profileIds = profiles.map((e) => e['id']).toList();

        // A. Check requests I SENT
        final sent = await _supabase
            .from('friendships')
            .select('receiver_id, status')
            .eq('requester_id', myId)
            .filter('receiver_id', 'in', profileIds); // <--- FIXED HERE

        for (var item in sent) {
          final status = item['status'];
          statusMap[item['receiver_id']] = (status == 'accepted')
              ? 'Friend'
              : 'Pending';
        }

        // B. Check requests I RECEIVED
        final received = await _supabase
            .from('friendships')
            .select('requester_id, status')
            .eq('receiver_id', myId)
            .filter('requester_id', 'in', profileIds); // <--- FIXED HERE

        for (var item in received) {
          final status = item['status'];
          // Even if they sent it to me, for the search screen, we can just show 'Pending' or 'Friend'
          statusMap[item['requester_id']] = (status == 'accepted')
              ? 'Friend'
              : 'Pending';
        }
      }

      if (mounted) {
        setState(() {
          _results = profiles;
          _dbFriendStatus = statusMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error finding people. Check your connection.";
        });
      }
    }
  }

  void _sendRequest(String userId) async {
    if (_pendingRequests.contains(userId)) return;

    setState(() {
      _pendingRequests.add(userId);
    });

    final myId = _supabase.auth.currentUser!.id;
    try {
      await _supabase.from('friendships').insert({
        'requester_id': myId,
        'receiver_id': userId,
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request sent!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pendingRequests.remove(userId);
        });

        final msg = e.toString().contains("23505")
            ? "Request already sent!"
            : "Could not send request.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Find People",
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textMain,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by username...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: AppColors.primary,
                  onPressed: () => _search(_searchController.text),
                ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onSubmitted: _search,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _results.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_rounded,
                          size: 60,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No users found",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      final userId = user['id'];

                      final fullName = user['full_name'] as String?;
                      final nickname = user['nickname'] as String?;
                      final displayName =
                          fullName ?? nickname ?? "Unknown User";
                      final char = displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : "?";

                      // 3. DETERMINE BUTTON STATE
                      final dbStatus =
                          _dbFriendStatus[userId]; // 'Friend', 'Pending', or null
                      final isOptimisticPending = _pendingRequests.contains(
                        userId,
                      );

                      // Logic: Is it disabled? What text? What color?
                      final bool isFriend = dbStatus == 'Friend';
                      final bool isPending =
                          dbStatus == 'Pending' || isOptimisticPending;

                      String buttonText = "Add";
                      Color btnBgColor = AppColors.primary;
                      Color btnFgColor = Colors.white;

                      if (isFriend) {
                        buttonText = "Friend";
                        btnBgColor = Colors.green.shade500;
                        btnFgColor = Colors.white;
                      } else if (isPending) {
                        buttonText = "Pending";
                        btnBgColor = Colors.grey.shade300;
                        btnFgColor = Colors.grey.shade600;
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            char,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: ElevatedButton(
                          // Disable button if Friend or Pending
                          onPressed: (isFriend || isPending)
                              ? null
                              : () => _sendRequest(userId),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: btnBgColor,
                            foregroundColor: btnFgColor,
                            // Ensure disabled look matches our custom colors if needed,
                            // or rely on default disabled style (which is greyish)
                            disabledBackgroundColor: btnBgColor,
                            disabledForegroundColor: btnFgColor,

                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                          child: Text(buttonText),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
