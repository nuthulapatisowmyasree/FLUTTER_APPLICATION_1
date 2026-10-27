import 'package:flutter/material.dart';
import '/database_helper.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() =>
      _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState
    extends State<DatabaseViewerScreen> {
  final DatabaseHelper db = DatabaseHelper.instance;

  int selectedTable = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  Future<void> loadDatabase() async {
    setState(() {
      isLoading = true;
    });

    try {
      users = await db.getUsers();
      reports = await db.getWasteReports();
      notifications = await db.getAllNotifications();
    } catch (e) {
      debugPrint('Database error: $e');
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F3),
      appBar: AppBar(
        title: const Text(
          'SQLite Database',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadDatabase,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Database',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                // TABLE SELECTOR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      _tableButton(
                        title: 'Users',
                        icon: Icons.people_alt_outlined,
                        count: users.length,
                        index: 0,
                      ),
                      const SizedBox(width: 10),
                      _tableButton(
                        title: 'Reports',
                        icon: Icons.delete_outline_rounded,
                        count: reports.length,
                        index: 1,
                      ),
                      const SizedBox(width: 10),
                      _tableButton(
                        title: 'Notifications',
                        icon: Icons.notifications_none_rounded,
                        count: notifications.length,
                        index: 2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _buildSelectedTable(),
                ),
              ],
            ),
    );
  }

  Widget _tableButton({
    required String title,
    required IconData icon,
    required int count,
    required int index,
  }) {
    final selected = selectedTable == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTable = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2E7D32)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD8E8DA),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count records',
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTable() {
    if (selectedTable == 0) {
      return _buildUsersTable();
    }

    if (selectedTable == 1) {
      return _buildReportsTable();
    }

    return _buildNotificationsTable();
  }

  // ============================================================
  // USERS
  // ============================================================

  Widget _buildUsersTable() {
    if (users.isEmpty) {
      return _emptyMessage('No users found');
    }

    return _dataCard(
      title: 'users',
      columns: const [
        'ID',
        'Full Name',
        'Email',
        'Phone',
        'Role',
      ],
      rows: users.map((user) {
        return [
          '${user['id']}',
          '${user['fullName']}',
          '${user['email']}',
          '${user['phone']}',
          '${user['role']}',
        ];
      }).toList(),
    );
  }

  // ============================================================
  // WASTE REPORTS
  // ============================================================

  Widget _buildReportsTable() {
    if (reports.isEmpty) {
      return _emptyMessage('No waste reports found');
    }

    return _dataCard(
      title: 'waste_reports',
      columns: const [
        'ID',
        'User',
        'Category',
        'Address',
        'Status',
      ],
      rows: reports.map((report) {
        return [
          '${report['id']}',
          '${report['userName'] ?? report['userId']}',
          '${report['category']}',
          '${report['address']}',
          '${report['status']}',
        ];
      }).toList(),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Widget _buildNotificationsTable() {
    if (notifications.isEmpty) {
      return _emptyMessage('No notifications found');
    }

    return _dataCard(
      title: 'notifications',
      columns: const [
        'ID',
        'User ID',
        'Title',
        'Message',
        'Read',
      ],
      rows: notifications.map((notification) {
        return [
          '${notification['id']}',
          '${notification['userId']}',
          '${notification['title']}',
          '${notification['message']}',
          notification['isRead'] == 1 ? 'Yes' : 'No',
        ];
      }).toList(),
    );
  }

  // ============================================================
  // DATA CARD
  // ============================================================

  Widget _dataCard({
    required String title,
    required List<String> columns,
    required List<List<String>> rows,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storage_rounded,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const Spacer(),
              Text(
                '${rows.length} records',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(
                    const Color(0xFFE8F5E9),
                  ),
                  columns: columns.map((column) {
                    return DataColumn(
                      label: Text(
                        column,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    );
                  }).toList(),
                  rows: rows.map((row) {
                    return DataRow(
                      cells: row.map((value) {
                        return DataCell(
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.storage_outlined,
            size: 55,
            color: Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}