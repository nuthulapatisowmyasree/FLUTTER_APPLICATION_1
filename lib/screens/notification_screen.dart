import 'package:flutter/material.dart';

import '../database_helper.dart';

class NotificationScreen extends StatefulWidget {
  final int userId;

  const NotificationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> loadNotifications() async {
    try {
      final data =
          await DatabaseHelper.instance.getUserNotifications(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead() async {
    await DatabaseHelper.instance
        .markAllNotificationsAsRead(widget.userId);

    await loadNotifications();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      final day =
          parsedDate.day.toString().padLeft(2, '0');

      final month =
          parsedDate.month.toString().padLeft(2, '0');

      final year = parsedDate.year.toString();

      final hour =
          parsedDate.hour.toString().padLeft(2, '0');

      final minute =
          parsedDate.minute.toString().padLeft(2, '0');

      return '$day/$month/$year  $hour:$minute';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // NOTIFICATION ICON
  // ============================================================

  IconData getNotificationIcon(String title) {
    final text = title.toLowerCase();

    if (text.contains('submitted')) {
      return Icons.assignment_turned_in_outlined;
    }

    if (text.contains('assigned')) {
      return Icons.person_pin_circle_outlined;
    }

    if (text.contains('collected')) {
      return Icons.delete_sweep_outlined;
    }

    if (text.contains('resolved')) {
      return Icons.check_circle_outline;
    }

    return Icons.notifications_none;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),

      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          notifications[index];

                      return _notificationCard(
                        notification,
                      );
                    },
                  ),
                ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 45,
                color: Colors.green.shade600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You are all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _notificationCard(
    Map<String, dynamic> notification,
  ) {
    final title =
        notification['title']?.toString() ??
            'Notification';

    final message =
        notification['message']?.toString() ??
            '';

    final createdAt =
        notification['createdAt']?.toString() ??
            '';

    final isRead =
        notification['isRead'] == 1;

    final notificationId =
        notification['id'] as int;

    return GestureDetector(
      onTap: () async {
        if (!isRead) {
          await DatabaseHelper.instance
              .markNotificationAsRead(
            notificationId,
          );

          await loadNotifications();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 15,
        ),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : Colors.green.shade50,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : Colors.green.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Icon(
                getNotificationIcon(title),
                color: Colors.green.shade700,
                size: 27,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFF1F2937),
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          width: 9,
                          height: 9,
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.green.shade600,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}