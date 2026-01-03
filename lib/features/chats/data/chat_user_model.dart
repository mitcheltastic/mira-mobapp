class ChatUser {
  final String name;
  final String
  avatarUrl; // We are hiding the Room ID inside here for navigation!
  final bool isOnline;

  ChatUser({required this.name, this.avatarUrl = '', this.isOnline = false});
}
