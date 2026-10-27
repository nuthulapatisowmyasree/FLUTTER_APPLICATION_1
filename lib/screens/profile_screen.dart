import 'package:flutter/material.dart';

import '../database_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;

  int reportsCount = 0;
  int resolvedCount = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    try {
      final userData =
          await DatabaseHelper.instance.getUserById(
        widget.userId,
      );

      final reports =
          await DatabaseHelper.instance.getSubmittedReportsCount(
        widget.userId,
      );

      final resolved =
          await DatabaseHelper.instance.getResolvedReportsCount(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        user = userData;
        reportsCount = reports;
        resolvedCount = resolved;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load profile: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DETAIL CARD
  // ============================================================

  Widget detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 24,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget statCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.green.shade700,
              size: 25,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F8F6),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.green.shade700,
        foregroundColor: Colors.white,

        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade700,
              ),
            )
          : RefreshIndicator(
              color: Colors.green.shade700,
              onRefresh: loadProfile,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // PROFILE HEADER
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(25),

                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          colors: [
                            Colors.green.shade700,
                            Colors.green.shade500,
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.green
                                .withValues(
                              alpha: 0.20,
                            ),
                            blurRadius: 15,
                            offset:
                                const Offset(0, 7),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // PROFILE ICON
                          Container(
                            width: 82,
                            height: 82,

                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              shape:
                                  BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),

                            child: Icon(
                              Icons.person,
                              size: 45,
                              color:
                                  Colors.green.shade700,
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // NAME
                          Text(
                            user?['fullName']
                                    ?.toString() ??
                                'User',

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          // EMAIL
                          Text(
                            user?['email']
                                    ?.toString() ??
                                '',

                            textAlign:
                                TextAlign.center,

                            style:
                                TextStyle(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.9,
                              ),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          // MEMBER LABEL
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),

                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(20),
                            ),

                            child: const Text(
                              'WasteCare Community Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // ACCOUNT DETAILS
                    // ==================================================

                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    detailCard(
                      icon:
                          Icons.person_outline,
                      title: 'Full Name',
                      value:
                          user?['fullName']
                                  ?.toString() ??
                              'Not available',
                    ),

                    detailCard(
                      icon:
                          Icons.email_outlined,
                      title: 'Email Address',
                      value:
                          user?['email']
                                  ?.toString() ??
                              'Not available',
                    ),

                    detailCard(
                      icon:
                          Icons.phone_outlined,
                      title: 'Phone Number',
                      value:
                          user?['phone']
                                  ?.toString() ??
                              'Not available',
                    ),

                    detailCard(
                      icon:
                          Icons.badge_outlined,
                      title: 'User ID',
                      value:
                          user?['id']
                                  ?.toString() ??
                              'Not available',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // ACTIVITY
                    // ==================================================

                    const Text(
                      'Your Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(
                      children: [
                        // REPORTS
                        statCard(
                          icon:
                              Icons.delete_outline,
                          value:
                              reportsCount.toString(),
                          title: 'Reports',
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        // RESOLVED
                        statCard(
                          icon: Icons
                              .check_circle_outline,
                          value:
                              resolvedCount.toString(),
                          title: 'Resolved',
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==================================================
                    // LOGOUT
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child:
                          OutlinedButton.icon(
                        onPressed: logout,

                        icon: const Icon(
                          Icons.logout,
                        ),

                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.red.shade600,

                          side: BorderSide(
                            color:
                                Colors.red.shade300,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // FOOTER
                    // ==================================================

                    Center(
                      child: Text(
                        'Together for a cleaner environment 🌱',
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}