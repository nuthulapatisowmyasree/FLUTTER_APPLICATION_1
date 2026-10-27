import 'package:flutter/material.dart';

import '../database_helper.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _db.getAllNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load notifications: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<void> _deleteNotification(
    int notificationId,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Notification',
          ),
          content: const Text(
            'Are you sure you want to delete this notification?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _db.deleteNotification(
        notificationId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification deleted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete notification: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Unknown date';
    }

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      final day = date.day
          .toString()
          .padLeft(2, '0');

      final month = date.month
          .toString()
          .padLeft(2, '0');

      final year = date.year.toString();

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute = date.minute
          .toString()
          .padLeft(2, '0');

      final period =
          date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year  $hour:$minute $period';
    } catch (_) {
      return value.toString();
    }
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _notificationCard(
    Map<String, dynamic> notification,
  ) {
    final int notificationId =
        (notification['id'] as num?)?.toInt() ?? 0;

    final int userId =
        (notification['userId'] as num?)?.toInt() ?? 0;

    final String title =
        notification['title']?.toString() ??
            'Notification';

    final String message =
        notification['message']?.toString() ??
            '';

    final bool isRead =
        (notification['isRead'] as num?)?.toInt() == 1;

    final String createdAt =
        _formatDate(notification['createdAt']);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ==================================================
            // ICON
            // ==================================================

            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.grey.shade100
                    : Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                isRead
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: isRead
                    ? Colors.grey.shade600
                    : Colors.green.shade700,
              ),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // CONTENT
            // ==================================================

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
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.green.shade50,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Colors.green.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      Icon(
                        Icons.person_outline,
                        size: 15,
                        color:
                            Colors.grey.shade500,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        'User ID: $userId',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey.shade500,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Icon(
                        Icons.access_time,
                        size: 15,
                        color:
                            Colors.grey.shade500,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          createdAt,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // DELETE
            // ==================================================

            IconButton(
              onPressed: () {
                _deleteNotification(
                  notificationId,
                );
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 450,
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.notifications_none,
                    size: 75,
                    color:
                        Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'No Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Notifications will appear here.',
                    style: TextStyle(
                      color:
                          Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor:
            Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _notifications.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh:
                      _loadNotifications,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        _notifications.length,
                    itemBuilder:
                        (context, index) {
                      return _notificationCard(
                        _notifications[index],
                      );
                    },
                  ),
                ),
    );
  }
}