import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.length;

  // ✅ Add new notifications (simulated when a message is sent)
  void addNotification(String senderEmail) {
    // If the sender already has an unread notification, increase the count
    int index = _notifications.indexWhere((n) => n['senderEmail'] == senderEmail);
    if (index != -1) {
      _notifications[index]['count'] += 1;
    } else {
      _notifications.add({
        'senderEmail': senderEmail,
        'count': 1,
        'read': false,
      });
    }
    notifyListeners();
  }

  // ✅ Mark all notifications as read
  void markAllAsRead() {
    _notifications.clear();
    notifyListeners();
  }
}
