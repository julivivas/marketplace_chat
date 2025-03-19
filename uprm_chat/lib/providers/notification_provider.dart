import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [
    {"id": 1, "message": "2 new messages from Gerald", "read": false},
    {"id": 2, "message": "New message from Alice", "read": false},
  ];

  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n['read']).length;

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }
}
