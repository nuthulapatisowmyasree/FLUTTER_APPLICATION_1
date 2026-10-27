import 'package:flutter/material.dart';

import '../database_helper.dart';
import 'notification_screen.dart';
import 'report_waste_screen.dart';
import 'location_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // =========================================================
  // DASHBOARD STATISTICS
  // =========================================================

  int submittedReports = 0;
  int resolvedReports = 0;

  List<Map<String, dynamic>> recentReports = [];

  bool isLoadingStats = true;

  // =========================================================
  // INIT STATE
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadDashboardStats();
  }

  // =========================================================
  // LOAD DASHBOARD DATA
  // =========================================================

  Future<void> loadDashboardStats() async {
    try {
      final submitted =
          await DatabaseHelper.instance.getSubmittedReportsCount(
        widget.userId,
      );

      final resolved =
          await DatabaseHelper.instance.getResolvedReportsCount(
        widget.userId,
      );

      final reports =
          await DatabaseHelper.instance.getUserWasteReports(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        submittedReports = submitted;
        resolvedReports = resolved;

        // Show only the latest 3 reports
        recentReports = reports.take(3).toList();

        isLoadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingStats = false;
      });

      debugPrint('DASHBOARD STATS ERROR: $e');
    }
  }

  // =========================================================
  // SERVICE CARD
  // =========================================================

  Widget serviceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                icon,
                color: Colors.green.shade700,
                size: 29,
              ),
            ),

            const SizedBox(width: 16),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
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

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STATISTICS CARD
  // =========================================================

  Widget statCard(
    IconData icon,
    String number,
    String title,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.green.shade600,
              size: 25,
            ),

            const SizedBox(height: 12),

            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ACTIVITY ITEM
  // =========================================================

  Widget activityItem(
    IconData icon,
    String title,
    String time,
  ) {
    return Row(
      children: [
        // Activity icon
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade600,
            size: 23,
          ),
        ),

        const SizedBox(width: 14),

        // Activity details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.recycling,
                size: 25,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'WasteCare',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // ===================================================
        // NOTIFICATION BUTTON
        // ===================================================

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(
                    userId: widget.userId,
                  ),
                ),
              );

              loadDashboardStats();
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),

          child: RefreshIndicator(
            onRefresh: loadDashboardStats,

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // WELCOME SECTION
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade700,
                          Colors.green.shade500,
                        ],
                      ),

                      borderRadius: BorderRadius.circular(25),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${widget.userName}! 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 7),

                              const Text(
                                'Keep your community clean.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Report waste and help make your surroundings cleaner.',
                                style: TextStyle(
                                  color: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Eco icon
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // OVERVIEW
                  // =================================================

                  const Text(
                    'Your Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ONLY TWO STATISTICS
                  Row(
                    children: [
                      statCard(
                        Icons.delete_outline,
                        isLoadingStats
                            ? '...'
                            : submittedReports.toString(),
                        'Reports Submitted',
                      ),

                      const SizedBox(width: 14),

                      statCard(
                        Icons.check_circle_outline,
                        isLoadingStats
                            ? '...'
                            : resolvedReports.toString(),
                        'Resolved Reports',
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // QUICK SERVICES
                  // =================================================

                  const Text(
                    'Quick Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 15),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth > 750 ? 2 : 1;

                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,

                        childAspectRatio:
                            columns == 2 ? 3.3 : 3.8,

                        children: [

                          // =========================================
                          // REPORT WASTE
                          // =========================================

                          serviceCard(
                            context,
                            icon: Icons.delete_outline,
                            title: 'Report Waste',
                            subtitle:
                                'Report garbage in your area',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReportWasteScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              );

                              loadDashboardStats();
                            },
                          ),

                          // =========================================
                          // MY REPORTS
                          // =========================================

                          serviceCard(
                            context,
                            icon: Icons.assignment_outlined,
                            title: 'My Reports',
                            subtitle:
                                'View your submitted waste reports',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyReportsScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              );

                              loadDashboardStats();
                            },
                          ),

                          // =========================================
                          // NOTIFICATIONS
                          // =========================================

                          serviceCard(
                            context,
                            icon: Icons.notifications_none,
                            title: 'Notifications',
                            subtitle:
                                'Check your latest updates',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NotificationScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              );

                              loadDashboardStats();
                            },
                          ),

                          // =========================================
                          // LOCATION
                          // =========================================

                          serviceCard(
                            context,
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            subtitle:
                                'View and manage your location',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LocationScreen(),
                                ),
                              );
                            },
                          ),

                          // =========================================
                          // MY PROFILE
                          // =========================================

                          serviceCard(
                            context,
                            icon: Icons.person_outline,
                            title: 'My Profile',
                            subtitle:
                                'View your account details',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // RECENT ACTIVITY
                  // =================================================

                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    // =================================================
                    // DYNAMIC RECENT ACTIVITY
                    // =================================================

                    child: recentReports.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 25,
                            ),

                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 45,
                                  color: Colors.grey.shade400,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'No recent activity',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Submit a waste report to see your activity here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )

                        : Column(
                            children: List.generate(
                              recentReports.length,
                              (index) {
                                final report =
                                    recentReports[index];

                                final status =
                                    report['status']?.toString() ??
                                        'Pending';

                                // =====================================
                                // SELECT ICON BASED ON STATUS
                                // =====================================

                                IconData icon;

                                if (status == 'Resolved') {
                                  icon = Icons.check_circle;
                                } else if (status ==
                                    'In Progress') {
                                  icon = Icons.sync;
                                } else {
                                  icon = Icons.delete_outline;
                                }

                                // =====================================
                                // ACTIVITY TEXT
                                // =====================================

                                String activityTitle;

                                if (status == 'Resolved') {
                                  activityTitle =
                                      'Waste report resolved';
                                } else if (status ==
                                    'In Progress') {
                                  activityTitle =
                                      'Waste report is in progress';
                                } else {
                                  activityTitle =
                                      'New waste report submitted';
                                }

                                // =====================================
                                // ACTIVITY ITEM
                                // =====================================

                                return Column(
                                  children: [
                                    activityItem(
                                      icon,
                                      activityTitle,
                                      _formatActivityTime(
                                        report['createdAt']
                                            ?.toString(),
                                      ),
                                    ),

                                    if (index !=
                                        recentReports.length - 1)
                                      const Divider(
                                        height: 25,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // FOOTER
                  // =================================================

                  Center(
                    child: Text(
                      'Together for a cleaner environment 🌱',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// FORMAT ACTIVITY TIME
// =============================================================

String _formatActivityTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return 'Recently';
  }

  final date = DateTime.tryParse(dateString);

  if (date == null) {
    return 'Recently';
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  // Less than one minute
  if (difference.inMinutes < 1) {
    return 'Just now';
  }

  // Less than one hour
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  }

  // Less than one day
  if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  }

  // Exactly one day
  if (difference.inDays == 1) {
    return 'Yesterday';
  }

  // Less than one week
  if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  }

  // Older reports
  return '${date.day}/${date.month}/${date.year}';
}