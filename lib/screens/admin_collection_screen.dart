import 'package:flutter/material.dart';

import '../database_helper.dart';

class AdminCollectionScreen extends StatefulWidget {
  const AdminCollectionScreen({super.key});

  @override
  State<AdminCollectionScreen> createState() =>
      _AdminCollectionScreenState();
}

class _AdminCollectionScreenState
    extends State<AdminCollectionScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _reports = [];

  bool _isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // ============================================================
  // LOAD REPORTS
  // ============================================================

  Future<void> _loadReports() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final reports = await _db.getWasteReports();

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load reports: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updateStatus(
    int reportId,
    int userId,
    String status,
  ) async {
    try {
      await _db.updateWasteReportStatus(
        reportId: reportId,
        status: status,
      );

      // Create notification for the user
      String message;

      switch (status) {
        case 'Resolved':
          message =
              'Your waste report has been resolved successfully.';
          break;

        case 'In Progress':
          message =
              'Your waste report is currently being processed.';
          break;

        default:
          message =
              'Your waste report status has been changed to Pending.';
      }

      await _db.insertNotification(
        userId: userId,
        title: 'Waste Report Status Updated',
        message: message,
      );

      await _loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report status updated to $status.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<void> _deleteReport(
    int reportId,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Report',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this waste report?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _db.deleteWasteReport(reportId);

      await _loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report deleted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete report: $e',
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

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year  $hour:$minute $period';
    } catch (_) {
      return value.toString();
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;

      case 'in progress':
        return Colors.orange;

      case 'pending':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Icons.check_circle;

      case 'in progress':
        return Icons.sync;

      case 'pending':
        return Icons.pending_actions;

      default:
        return Icons.info_outline;
    }
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget _reportCard(
    Map<String, dynamic> report,
  ) {
    final int reportId =
        (report['id'] as num?)?.toInt() ?? 0;

    final int userId =
        (report['userId'] as num?)?.toInt() ?? 0;

    final String category =
        report['category']?.toString() ?? 'Unknown';

    final String description =
        report['description']?.toString() ?? '';

    final String address =
        report['address']?.toString() ??
            'Address unavailable';

    final String status =
        report['status']?.toString() ?? 'Pending';

    final String userName =
        report['userName']?.toString() ??
            'Unknown User';

    final String userEmail =
        report['userEmail']?.toString() ??
            'Not available';

    final String userPhone =
        report['userPhone']?.toString() ??
            'Not available';

    final String createdAt =
        _formatDate(report['createdAt']);

    final Color statusColor =
        _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.delete_sweep_outlined,
                    color: Colors.green.shade700,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Report ID: $reportId',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteReport(reportId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // STATUS
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    _statusIcon(status),
                    size: 18,
                    color: statusColor,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // USER DETAILS
            // ==================================================

            const Text(
              'Reported By',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _infoRow(
              Icons.person_outline,
              'Name',
              userName,
            ),

            const SizedBox(height: 7),

            _infoRow(
              Icons.email_outlined,
              'Email',
              userEmail,
            ),

            const SizedBox(height: 7),

            _infoRow(
              Icons.phone_outlined,
              'Phone',
              userPhone,
            ),

            const SizedBox(height: 7),

            _infoRow(
              Icons.badge_outlined,
              'User ID',
              userId.toString(),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            if (description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),
            ],

            // ==================================================
            // ADDRESS
            // ==================================================

            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.red.shade400,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // DATE
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 17,
                  color: Colors.grey.shade500,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    createdAt,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 14),

            // ==================================================
            // STATUS DROPDOWN
            // ==================================================

            DropdownButtonFormField<String>(
              initialValue:
                  status == 'Pending' ||
                          status == 'In Progress' ||
                          status == 'Resolved'
                      ? status
                      : 'Pending',

              decoration: InputDecoration(
                labelText: 'Report Status',
                prefixIcon:
                    const Icon(Icons.sync),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Pending',
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: 'In Progress',
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(
                  value: 'Resolved',
                  child: Text('Resolved'),
                ),
              ],

              onChanged: (value) {
                if (value == null) return;

                if (value != status) {
                  _updateStatus(
                    reportId,
                    userId,
                    value,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 55,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'No Waste Reports',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'No waste reports are available.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Manage Waste Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(
                color: Colors.green.shade700,
              ),
            )
          : _reports.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder:
                        (context, index) {
                      return _reportCard(
                        _reports[index],
                      );
                    },
                  ),
                ),
    );
  }
}