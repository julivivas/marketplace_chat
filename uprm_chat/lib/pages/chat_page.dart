import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uprm_chat/components/chat_bubble.dart';
import 'package:uprm_chat/components/my_textfield.dart';
import 'package:uprm_chat/services/auth/auth_service.dart';
import 'package:uprm_chat/services/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail; // To see who we chatting with
  final String receiverID;

  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messageController = TextEditingController();

  //auth and chat services
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  //for the textfield focus (when typing go to the most recent text)
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add listener to focus mode
    myFocusNode.addListener(() {
      //cause a delay so that the keyboard has time to show up
      //then the amount of remaining space will be calculated ,
      //then scroll down
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // wait a bit for listview to be built, then scroll to bttowm
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message (UI related)
  void sendMessage() async {
    //Only send message if their is something in the textfield to send
    if (_messageController.text.isNotEmpty) {
      //send the message
      await _chatServices.sendMessage(
        widget.receiverID,
        _messageController.text,
      );

      //clear text controller
      _messageController.clear();

      scrollDown(); // scrolls down when i type new message
    }
  }

  @override
  Widget build(BuildContext context) {
    //Builds our UI
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          //display all the messages
          Expanded(child: _buildMessageList()),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatServices.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        //return list view
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser =
        data['senderID'] ==
        _authService
            .getCurrentUser()!
            .uid; // checks if the user of the message is the current user that signed in

    //align message to right if sender is current suer , otherwise left
    var alingment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alingment,
      child: ChatBubble(message: data["message"], isCurrentUser: isCurrentUser),
    );
  }

  //build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          //Textfield should take up most of the space
          Expanded(
            child: MyTextfield(
              hintText: "Type a message",
              obscureText: false,
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),

          //Send button
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 48, 130, 51),
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
