import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uprm_chat/models/message.dart';
import 'package:uprm_chat/services/notification_service.dart';


class ChatServices {
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; //user info
  final NotificationService _notificationService = NotificationService(); // Add this

  //get user stream (in order to display user)
  /* 
  [
  List<Map<String,dynamic>> =
  {
  'email' = test@gmail.com
  'id' = ...
  },
  {
  'email' = test@gmail.com
  'id' = ...
  }, 
  ]
  */

  // Stream is gonna listen to the firestore
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //go through each individual user
        final user = doc.data();

        //return user
        return user;
      }).toList();
    });
  }

  //methods for send message
  Future<void> sendMessage(String receiverID, message) async {
  // get current user info
  final String currentUserID = _auth.currentUser!.uid;
  final String currentUserEmail = _auth.currentUser!.email!;
  final Timestamp timestamp = Timestamp.now(); // when the message is sent

  // create a new message
  Message newMessage = Message(
    senderID: currentUserID,
    senderEmail: currentUserEmail,
    receiverID: receiverID,
    message: message,
    timestamp: timestamp,
  );

  // construct chat room ID for the two users (sorted to ensure uniqueness)
  List<String> ids = [currentUserID, receiverID];
  ids.sort(); // ensure the chat room ID is the same for any 2 people
  String chatRoomID = ids.join('_');

  // add new message to database
  await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .add(newMessage.toMap());

  // Send notification to receiver
  await _notificationService.addNotification(receiverID, "New message from $currentUserEmail");
}


  //get message
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //Contruct a chatroom ID for the users
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
