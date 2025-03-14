import 'package:flutter/material.dart';
import 'package:uprm_chat/components/my_drawer.dart';
import 'package:uprm_chat/components/user_tile.dart';
import 'package:uprm_chat/pages/chat_page.dart';
import 'package:uprm_chat/services/auth/auth_service.dart';
import 'package:uprm_chat/services/chat/chat_services.dart';

//Format for our Home_page

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //chat & auth services
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users except for current logged in user

  Widget _buildUserList() {
    // in order to keep code clean
    return StreamBuilder(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Text("Error");
        }
        //loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        //return list view
        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    (userData) => _buildUserListItem(userData, context),
                  )
                  .toList(),
        );
      },
    );
  }

  //Build individual list tile for user
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // display all users except current user
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          //tapped on a user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverEmail: userData["email"],
                    receiverID: userData['uid'],
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
