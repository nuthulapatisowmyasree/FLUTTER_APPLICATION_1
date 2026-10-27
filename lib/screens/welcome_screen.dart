import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _slideAnimation;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    // Fade Animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Slide Animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION - NAMED ROUTES
  // ============================================================

  void openLogin(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/login',
    );
  }

  void openRegister(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/register',
    );
  }

  void openAdminLogin(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/admin-login',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F3),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,

          child: SlideTransition(
            position: _slideAnimation,

            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),

                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),

                  child: Column(
                    children: [

                      // ==================================================
                      // HEADER
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Container(
                            width: 58,
                            height: 58,

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF43A047),

                              shape:
                                  BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.green.withValues(
                                    alpha: 0.25,
                                  ),

                                  blurRadius: 15,

                                  offset:
                                      const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.recycling_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),

                          const SizedBox(width: 15),

                          const Text(
                            'WasteCare',

                            style: TextStyle(
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Smart Waste Reporting for Cleaner Communities',

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // HERO SECTION
                      // ==================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(30),

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFFE8F5E9),
                              Color(0xFFC8E6C9),
                            ],

                            begin:
                                Alignment.topLeft,

                            end:
                                Alignment.bottomRight,
                          ),

                          borderRadius:
                              BorderRadius.circular(28),

                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.green.withValues(
                                alpha: 0.06,
                              ),

                              blurRadius: 20,

                              offset:
                                  const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: width > 700
                            ? Row(
                                children: [

                                  Expanded(
                                    child:
                                        _heroText(),
                                  ),

                                  const SizedBox(
                                    width: 25,
                                  ),

                                  _heroIllustration(),
                                ],
                              )
                            : Column(
                                children: [

                                  _heroIllustration(),

                                  const SizedBox(
                                    height: 20,
                                  ),

                                  _heroText(),
                                ],
                              ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // FEATURES TITLE
                      // ==================================================

                      const Align(
                        alignment:
                            Alignment.centerLeft,

                        child: Text(
                          'Everything you need',

                          style: TextStyle(
                            fontSize: 23,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFF183B20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Align(
                        alignment:
                            Alignment.centerLeft,

                        child: Text(
                          'Explore the features available in WasteCare',

                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // FEATURES
                      // INFORMATION ONLY
                      // ==================================================

                      LayoutBuilder(
                        builder:
                            (context, constraints) {

                          int crossAxisCount;

                          if (constraints.maxWidth >=
                              900) {
                            crossAxisCount = 3;
                          } else if (constraints
                                  .maxWidth >=
                              600) {
                            crossAxisCount = 2;
                          } else {
                            crossAxisCount = 1;
                          }

                          return GridView.count(
                            crossAxisCount:
                                crossAxisCount,

                            shrinkWrap: true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            crossAxisSpacing: 15,

                            mainAxisSpacing: 15,

                            childAspectRatio:
                                crossAxisCount == 1
                                    ? 3.0
                                    : 1.55,

                            children: [

                              _featureCard(
                                icon:
                                    Icons.recycling_rounded,

                                iconColor:
                                    const Color(
                                  0xFF2E7D32,
                                ),

                                backgroundColor:
                                    const Color(
                                  0xFFE8F5E9,
                                ),

                                title:
                                    'Report Waste',

                                description:
                                    'Report waste problems with photo and location.',
                              ),

                              _featureCard(
                                icon:
                                    Icons.location_on_rounded,

                                iconColor:
                                    const Color(
                                  0xFF1976D2,
                                ),

                                backgroundColor:
                                    const Color(
                                  0xFFE3F2FD,
                                ),

                                title:
                                    'Track Reports',

                                description:
                                    'Track your submitted waste reports.',
                              ),

                              _featureCard(
                                icon:
                                    Icons.notifications_rounded,

                                iconColor:
                                    const Color(
                                  0xFFF57C00,
                                ),

                                backgroundColor:
                                    const Color(
                                  0xFFFFF3E0,
                                ),

                                title:
                                    'Notifications',

                                description:
                                    'Stay updated about your reports.',
                              ),

                              _featureCard(
                                icon:
                                    Icons.menu_book_rounded,

                                iconColor:
                                    const Color(
                                  0xFF7B1FA2,
                                ),

                                backgroundColor:
                                    const Color(
                                  0xFFF3E5F5,
                                ),

                                title:
                                    'Waste Guide',

                                description:
                                    'Learn about proper waste disposal.',
                              ),

                              _featureCard(
                                icon:
                                    Icons.person_rounded,

                                iconColor:
                                    const Color(
                                  0xFF00838F,
                                ),

                                backgroundColor:
                                    const Color(
                                  0xFFE0F7FA,
                                ),

                                title:
                                    'My Profile',

                                description:
                                    'Manage your account information.',
                              ),

                              _featureCard(
                                icon:
                                    Icons.admin_panel_settings_rounded,

                                iconColor:
                                    const Color(
                                  0xFFC62828,
                                ),

                                backgroundColor:
                                    const Color(
                                  0xFFFFEBEE,
                                ),

                                title:
                                    'Admin Panel',

                                description:
                                    'Manage reports and users.',
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // GET STARTED
                      // ==================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(24),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(
                                alpha: 0.06,
                              ),

                              blurRadius: 20,

                              offset:
                                  const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            const Text(
                              'Get Started with WasteCare',

                              style: TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xFF183B20),
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Choose an option to continue',

                              style: TextStyle(
                                color:
                                    Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // LOGIN
                            // ==================================================

                            SizedBox(
                              width:
                                  double.infinity,

                              height: 52,

                              child:
                                  ElevatedButton.icon(
                                onPressed: () =>
                                    openLogin(
                                  context,
                                ),

                                icon: const Icon(
                                  Icons.login_rounded,
                                ),

                                label: const Text(
                                  'Login',

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF2E7D32,
                                  ),

                                  foregroundColor:
                                      Colors.white,

                                  elevation: 3,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // CREATE ACCOUNT
                            // ==================================================

                            SizedBox(
                              width:
                                  double.infinity,

                              height: 52,

                              child:
                                  OutlinedButton.icon(
                                onPressed: () =>
                                    openRegister(
                                  context,
                                ),

                                icon: const Icon(
                                  Icons
                                      .person_add_alt_1_rounded,
                                ),

                                label: const Text(
                                  'Create Account',

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(
                                    0xFF2E7D32,
                                  ),

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFF43A047,
                                    ),

                                    width: 1.5,
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // ADMIN LOGIN
                            // ==================================================

                            SizedBox(
                              width:
                                  double.infinity,

                              height: 52,

                              child:
                                  TextButton.icon(
                                onPressed: () =>
                                    openAdminLogin(
                                  context,
                                ),

                                icon: const Icon(
                                  Icons
                                      .admin_panel_settings_rounded,
                                ),

                                label: const Text(
                                  'Admin Login',

                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                style:
                                    TextButton.styleFrom(
                                  foregroundColor:
                                      const Color(
                                    0xFF455A64,
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // FOOTER
                      // ==================================================

                      const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Icon(
                            Icons.eco_rounded,
                            size: 18,
                            color:
                                Color(0xFF43A047),
                          ),

                          SizedBox(width: 7),

                          Text(
                            'Together for a cleaner and greener future',

                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.black45,
                              fontStyle:
                                  FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO TEXT
  // ============================================================

  Widget _heroText() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          'Together for a',

          style: TextStyle(
            fontSize: 27,
            fontWeight:
                FontWeight.w600,
            color:
                Color(0xFF16451C),
          ),
        ),

        const Text(
          'Cleaner & Greener Future',

          style: TextStyle(
            fontSize: 30,
            fontWeight:
                FontWeight.w800,
            color:
                Color(0xFF2E7D32),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Report waste, track your reports and help keep your community clean.',

          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color:
                Color(0xFF45624A),
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white.withValues(
              alpha: 0.75,
            ),

            borderRadius:
                BorderRadius.circular(30),
          ),

          child: const Row(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color:
                    Color(0xFF43A047),
              ),

              SizedBox(width: 7),

              Text(
                'Simple • Smart • Sustainable',

                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF356B3B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO ILLUSTRATION
  // ============================================================

  Widget _heroIllustration() {
    return Container(
      width: 260,
      height: 190,

      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.65,
        ),

        borderRadius:
            BorderRadius.circular(30),
      ),

      child: Stack(
        alignment:
            Alignment.center,

        children: [

          Positioned(
            top: 18,

            child: Icon(
              Icons.eco_rounded,
              size: 85,

              color:
                  const Color(
                0xFF43A047,
              ).withValues(
                alpha: 0.25,
              ),
            ),
          ),

          Positioned(
            bottom: 25,
            left: 42,

            child: _bin(
              const Color(0xFF43A047),
              Icons.recycling_rounded,
            ),
          ),

          Positioned(
            bottom: 25,
            right: 42,

            child: _bin(
              const Color(0xFF1976D2),
              Icons.delete_outline_rounded,
            ),
          ),

          const Positioned(
            top: 85,

            child: Icon(
              Icons.public_rounded,
              size: 72,
              color:
                  Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WASTE BIN
  // ============================================================

  Widget _bin(
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 65,
      height: 75,

      decoration:
          BoxDecoration(
        color: color,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Icon(
        icon,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  // ============================================================
  // FEATURE CARD
  //
  // INFORMATION ONLY
  // NO NAVIGATION
  // ============================================================

  Widget _featureCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: backgroundColor,
          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.04,
            ),

            blurRadius: 12,

            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 55,
            
            height: 55,

            decoration:
                BoxDecoration(
              color: backgroundColor,
              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF173B20),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 12.5,
                    height: 1.3,
                    color:
                        Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}