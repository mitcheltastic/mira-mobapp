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
    });

    final myId = _supabase.auth.currentUser!.id;

    try {
      // 1. Search Profiles
      // Uses 'ilike' for case-insensitive search on BOTH columns
      final data = await _supabase
          .from('profiles')
          .select()
          .or('full_name.ilike.%$query%,nickname.ilike.%$query%')
          .neq('id', myId)
          .limit(20);

      if (mounted) {
        setState(() {
          _results = List<Map<String, dynamic>>.from(data);
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
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Error code 23505 = Unique Violation (Request already exists)
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
          // SEARCH INPUT
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

          // LOADING / ERROR / LIST
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

                      // Prioritize full_name, fallback to nickname, fallback to "Unknown"
                      final fullName = user['full_name'] as String?;
                      final nickname = user['nickname'] as String?;

                      final displayName =
                          fullName ?? nickname ?? "Unknown User";
                      final char = displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : "?";

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
                          displayName, // FIXED: Was 'name' before
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _sendRequest(user['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                          child: const Text("Add"),
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
