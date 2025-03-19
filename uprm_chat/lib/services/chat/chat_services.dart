import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uprm_chat/models/message.dart';
import 'package:uprm_chat/providers/notification_provider.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user stream (to display users)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // ✅ Ensure notifications go **only** to the receiver
  Future<void> sendMessage(
      String receiverID, String message, NotificationProvider notifier) async {
    final String senderID = _auth.currentUser!.uid;
    final String senderEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: senderID,
      senderEmail: senderEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Construct a unique chat room ID
    List<String> ids = [senderID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Save message to Firestore
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // ✅ Fix: Add notification for **receiver** only
    if (senderID != receiverID) { 
      notifier.addNotification(receiverID, senderEmail); // Send only to receiver
    }
  }

  // Get messages between two users
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
