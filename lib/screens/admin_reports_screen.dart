import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../database_helper.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // ============================================================
  // LOAD ALL REPORTS
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
  // UPDATE REPORT STATUS
  // ============================================================

  Future<void> _updateStatus(
    int reportId,
    int userId,
    String newStatus,
  ) async {
    try {
      await _db.updateWasteReportStatus(
        reportId: reportId,
        status: newStatus,
      );

      // --------------------------------------------------------
      // CREATE NOTIFICATION FOR USER
      // --------------------------------------------------------

      String message;

      if (newStatus == 'Resolved') {
        message =
            'Your waste report has been resolved successfully.';
      } else if (newStatus == 'In Progress') {
        message =
            'Your waste report is currently being processed.';
      } else {
        message =
            'Your waste report status has been changed to Pending.';
      }

      await _db.insertNotification(
        userId: userId,
        title: 'Report Status Updated',
        message: message,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report status changed to $newStatus',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadReports();
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
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
                Navigator.pop(
                  context,
                  false,
                );
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
                Navigator.pop(
                  context,
                  true,
                );
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
      await _db.deleteWasteReport(reportId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report deleted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadReports();
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
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;

      case 'in progress':
        return Colors.orange;

      case 'pending':
      default:
        return Colors.blue;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Icons.check_circle_outline;

      case 'in progress':
        return Icons.autorenew;

      case 'pending':
      default:
        return Icons.pending_actions;
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Date unavailable';
    }

    try {
      final date = DateTime.parse(value);

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour % 12 == 0
          ? 12
          : date.hour % 12;

      final minute = date.minute.toString().padLeft(2, '0');

      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year • $hour:$minute $period';
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // USER INFORMATION ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.grey.shade600,
          ),

          const SizedBox(
            width: 10,
          ),

          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget _buildReportCard(
    Map<String, dynamic> report,
  ) {
    final int reportId =
        (report['id'] as num?)?.toInt() ?? 0;

    final int userId =
        (report['userId'] as num?)?.toInt() ?? 0;

    final String category =
        report['category']?.toString() ?? 'Unknown';

    final String description =
        report['description']?.toString() ??
            'No description';

    final String address =
        report['address']?.toString() ??
            'Location unavailable';

    final String status =
        report['status']?.toString() ?? 'Pending';

    final String createdAt =
        report['createdAt']?.toString() ?? '';

    // ----------------------------------------------------------
    // USER DETAILS FROM JOIN
    // ----------------------------------------------------------

    final String userName =
        report['userName']?.toString() ??
            'Unknown User';

    final String userEmail =
        report['userEmail']?.toString() ??
            'Email unavailable';

    final String userPhone =
        report['userPhone']?.toString() ??
            'Phone unavailable';

    // ----------------------------------------------------------
    // IMAGE DATA
    // ----------------------------------------------------------

    final dynamic imageData = report['image'];

    Uint8List? imageBytes;

    if (imageData is Uint8List) {
      imageBytes = imageData;
    } else if (imageData is List<int>) {
      imageBytes = Uint8List.fromList(
        imageData,
      );
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                Expanded(
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: Colors.green
                              .withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.green,
                          size: 25,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              'Report #$reportId',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                // STATUS BADGE
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status)
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(status),
                        size: 15,
                        color:
                            _statusColor(status),
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        status,
                        style: TextStyle(
                          color:
                              _statusColor(status),
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // IMAGE
            // ==================================================

            if (imageBytes != null &&
                imageBytes.isNotEmpty)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(15),
                child: Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),

            if (imageBytes != null &&
                imageBytes.isNotEmpty)
              const SizedBox(
                height: 18,
              ),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 19,
                        color:
                            Colors.grey.shade700,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    description,
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // LOCATION
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red
                    .withValues(
                  alpha: 0.05,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 21,
                    color: Colors.red,
                  ),

                  const SizedBox(
                    width: 9,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          address,
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // USER DETAILS
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(
                  alpha: 0.05,
                ),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.green
                      .withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green
                              .withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(
                        width: 9,
                      ),

                      const Text(
                        'Reported By',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _infoRow(
                    icon:
                        Icons.person_outline,
                    label: 'Name',
                    value: userName,
                  ),

                  _infoRow(
                    icon:
                        Icons.email_outlined,
                    label: 'Email',
                    value: userEmail,
                  ),

                  _infoRow(
                    icon:
                        Icons.phone_outlined,
                    label: 'Phone',
                    value: userPhone,
                  ),

                  _infoRow(
                    icon:
                        Icons.badge_outlined,
                    label: 'User ID',
                    value: userId.toString(),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // DATE
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(
                  width: 7,
                ),

                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // STATUS DROPDOWN
            // ==================================================

            DropdownButtonFormField<String>(
              initialValue: [
                'Pending',
                'In Progress',
                'Resolved',
              ].contains(status)
                  ? status
                  : 'Pending',
              decoration:
                  InputDecoration(
                labelText: 'Update Status',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.sync,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Pending',
                  child: Text(
                    'Pending',
                  ),
                ),
                DropdownMenuItem(
                  value: 'In Progress',
                  child: Text(
                    'In Progress',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Resolved',
                  child: Text(
                    'Resolved',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null &&
                    value != status) {
                  _updateStatus(
                    reportId,
                    userId,
                    value,
                  );
                }
              },
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // DELETE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _deleteReport(
                    reportId,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete Report',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
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
      onRefresh: _loadReports,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withValues(
                          alpha: 0.08,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inbox_outlined,
                        size: 65,
                        color:
                            Colors.green.shade400,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'No Waste Reports',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Submitted waste reports will appear here.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FC),

      appBar: AppBar(
        title: const Text(
          'Manage Waste Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadReports,
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
          : _reports.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        _reports.length,
                    itemBuilder:
                        (context, index) {
                      return _buildReportCard(
                        _reports[index],
                      );
                    },
                  ),
                ),
    );
  }
}