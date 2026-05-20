import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType {
  order,
  coupon,
  review,
  general,
}

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return AppNotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: AppNotificationType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => AppNotificationType.general,
      ),
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] == null
          ? DateTime.now()
          : (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    AppNotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}