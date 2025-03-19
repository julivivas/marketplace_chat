import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _userNotifications = {};

  // ✅ Get notifications for a specific user
  List<Map<String, dynamic>> getNotificationsForUser(String userID) {
    return _userNotifications[userID] ?? [];
  }

  // ✅ Get unread count for a specific user
  int getUnreadCountForUser(String userID) {
    return _userNotifications[userID]?.length ?? 0;
  }

  // ✅ Add new notification for a specific receiver
  void addNotification(String receiverID, String senderEmail) {
    if (!_userNotifications.containsKey(receiverID)) {
      _userNotifications[receiverID] = [];
    }

    // Check if sender already has an unread notification
    int index = _userNotifications[receiverID]!
        .indexWhere((n) => n['senderEmail'] == senderEmail);

    if (index != -1) {
      // If sender already has an unread notification, increase the count
      _userNotifications[receiverID]![index]['count'] += 1;
    } else {
      // Otherwise, add a new notification entry
      _userNotifications[receiverID]!.add({
        'senderEmail': senderEmail,
        'count': 1,
        'read': false,
      });
    }
    notifyListeners();
  }

  // ✅ Mark all notifications as read for a specific user
  void markAllAsRead(String userID) {
    if (_userNotifications.containsKey(userID)) {
      _userNotifications[userID]!.clear();
    }
    notifyListeners();
  }
}
