import 'package:flutter/material.dart';

import 'database_viewer_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_users_screen.dart';
import 'admin_notifications_screen.dart';

import '../database_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AdminDashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============================================================
  // DASHBOARD STATISTICS
  // ============================================================

  int _totalUsers = 0;
  int _totalReports = 0;
  int _pendingReports = 0;
  int _resolvedReports = 0;

  bool _isLoadingStats = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  // ============================================================
  // LOAD DASHBOARD STATISTICS
  // ============================================================

  Future<void> _loadDashboardStats() async {
    if (mounted) {
      setState(() {
        _isLoadingStats = true;
      });
    }

    try {
      final users = await _db.getUsers();
      final reports = await _db.getWasteReports();

      int normalUsers = 0;
      int pending = 0;
      int resolved = 0;

      // ========================================================
      // USER STATISTICS
      // ========================================================

      for (final user in users) {
        final role =
            user['role']?.toString().toLowerCase() ?? 'user';

        if (role != 'admin') {
          normalUsers++;
        }
      }

      // ========================================================
      // REPORT STATISTICS
      // ========================================================

      for (final report in reports) {
        final status =
            report['status']?.toString().toLowerCase().trim() ??
                'pending';

        if (status == 'pending') {
          pending++;
        }

        if (status == 'resolved') {
          resolved++;
        }
      }

      if (!mounted) return;

      setState(() {
        _totalUsers = normalUsers;
        _totalReports = reports.length;
        _pendingReports = pending;
        _resolvedReports = resolved;
        _isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStats = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load dashboard statistics: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadDashboardStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // WELCOME SECTION
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 45,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Welcome, ${widget.userName}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Manage WasteCare from your admin panel.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // OVERVIEW
              // ==================================================

              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // STAT CARDS - ROW 1
              // ==================================================

              Row(
                children: [

                  Expanded(
                    child: _statCard(
                      icon: Icons.people,
                      title: 'Users',
                      value: _isLoadingStats
                          ? '...'
                          : _totalUsers.toString(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      icon: Icons.delete_outline,
                      title: 'Reports',
                      value: _isLoadingStats
                          ? '...'
                          : _totalReports.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // STAT CARDS - ROW 2
              // ==================================================

              Row(
                children: [

                  Expanded(
                    child: _statCard(
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      value: _isLoadingStats
                          ? '...'
                          : _pendingReports.toString(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      icon: Icons.check_circle_outline,
                      title: 'Resolved',
                      value: _isLoadingStats
                          ? '...'
                          : _resolvedReports.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================
              // MANAGEMENT
              // ==================================================

              const Text(
                'Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // MANAGE WASTE REPORTS
              // ==================================================

              _managementCard(
                icon: Icons.assignment_outlined,
                title: 'Manage Waste Reports',
                subtitle:
                    'View and update waste reports submitted by users.',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminReportsScreen(),
                    ),
                  );

                  await _loadDashboardStats();
                },
              ),

              const SizedBox(height: 12),

              // ==================================================
              // MANAGE USERS
              // ==================================================

              _managementCard(
                icon: Icons.people_outline,
                title: 'Manage Users',
                subtitle:
                    'View and manage registered users.',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminUsersScreen(),
                    ),
                  );

                  await _loadDashboardStats();
                },
              ),

              const SizedBox(height: 12),

              // ==================================================
              // NOTIFICATIONS
              // ==================================================

              _managementCard(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle:
                    'View and manage notifications and updates.',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminNotificationsScreen(),
                    ),
                  );

                  await _loadDashboardStats();
                },
              ),

              const SizedBox(height: 12),

              // ==================================================
              // SQLITE DATABASE
              // ==================================================

              _managementCard(
                icon: Icons.storage_rounded,
                title: 'SQLite Database',
                subtitle:
                    'View users, waste reports and notifications stored in SQLite.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const DatabaseViewerScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ==================================================
              // ADMIN INFORMATION
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green.shade50,

                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.green.shade700,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Administrator',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            'Admin ID: ${widget.userId}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // LOGOUT
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(Icons.logout),

                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,

                    side: const BorderSide(
                      color: Colors.red,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: Colors.green.shade700,
            size: 30,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MANAGEMENT CARD
  // ============================================================

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
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

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}