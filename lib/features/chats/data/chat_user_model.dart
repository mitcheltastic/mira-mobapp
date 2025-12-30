// ---------------------------------------------------------
// MODEL USER (Orang yang kita chat)
// ---------------------------------------------------------
class ChatUser {
  final String name;
  final String avatarUrl; // Bisa diganti network image nanti
  final bool isOnline;

  ChatUser({
    required this.name,
    this.avatarUrl = '',
    this.isOnline = false,
  });
}

// ---------------------------------------------------------
// MODEL PESAN (Isi chattingan)
// ---------------------------------------------------------
class ChatMessage {
  final String text;
  final bool isMe;     // True jika kita yang kirim, False jika orang lain
  final String time;   // Jam pesan dikirim

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

// ---------------------------------------------------------
// DATA DUMMY (Untuk List Lobby)
// ---------------------------------------------------------
// Kita modifikasi sedikit agar sesuai dengan ChatUser di atas
class ChatPreview {
  final ChatUser user;
  final String lastMessage;
  final String time;
  final int unreadCount;

  ChatPreview({
    required this.user,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}

final List<ChatPreview> dummyChats = [
  ChatPreview(
    user: ChatUser(name: "Dosen Pembimbing", isOnline: true),
    lastMessage: "Revisi bab 3 tolong segera dikirim ya.",
    time: "10:30",
    unreadCount: 2,
  ),
  ChatPreview(
    user: ChatUser(name: "Tim IoT Project", isOnline: false),
    lastMessage: "Sensor ultrasoniknya aman bro?",
    time: "09:41",
    unreadCount: 5,
  ),
  ChatPreview(
    user: ChatUser(name: "Sarah (Sekretaris)", isOnline: true),
    lastMessage: "Notulensi rapat ada di drive.",
    time: "Kemarin",
    unreadCount: 0,
  ),
];