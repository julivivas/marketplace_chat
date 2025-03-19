import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uprm_chat/components/my_drawer.dart';
import 'package:uprm_chat/components/user_tile.dart';
import 'package:uprm_chat/pages/chat_page.dart';
import 'package:uprm_chat/services/auth/auth_service.dart';
import 'package:uprm_chat/services/chat/chat_services.dart';
import 'package:uprm_chat/providers/notification_provider.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          _buildNotificationIcon(context), // ✅ Add the notification icon
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifier, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                _showNotificationPreview(context, notifier);
              },
            ),
            if (notifier.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    notifier.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationPreview(BuildContext context, NotificationProvider notifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: notifier.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifier.notifications[index];
                  return ListTile(
                    title: Text(notification['message']),
                    leading: Icon(notification['read'] ? Icons.check : Icons.mark_chat_unread),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.markAllAsRead();
                Navigator.pop(context);
              },
              child: const Text("Mark all as read"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        if (snapshot.connectionState == ConnectionState.waiting) return const Text("Loading...");

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
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
