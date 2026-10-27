import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../user_provider.dart';
import '../database_helper.dart';

import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? successMessage;

  const LoginScreen({
    super.key,
    this.successMessage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool isLoading = false;
  bool obscurePassword = true;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Check default admin
    DatabaseHelper.instance.checkAdmin();

    // Show registration success message
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showMessage(
            widget.successMessage!,
            Colors.green,
          );
        }
      });
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> loginUser() async {
    final String email =
        emailController.text.trim().toLowerCase();

    final String password =
        passwordController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (email.isEmpty || password.isEmpty) {
      showMessage(
        'Please enter email and password.',
        Colors.red,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // GET USER FROM SQLITE
      // ========================================================

      final List<Map<String, dynamic>> users =
          await DatabaseHelper.instance.getUser(
        email,
        password,
      );

      debugPrint(
        'LOGIN EMAIL: $email',
      );

      debugPrint(
        'LOGIN USERS FOUND: $users',
      );

      if (!mounted) return;

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (users.isNotEmpty) {
        final Map<String, dynamic> user =
            users.first;

        final int userId =
            (user['id'] as num).toInt();

        final String userName =
            user['fullName']?.toString() ??
                'User';

        final String role =
            user['role']
                    ?.toString()
                    .toLowerCase() ??
                'user';

        debugPrint(
          'LOGIN USER ID: $userId',
        );

        debugPrint(
          'LOGIN USER NAME: $userName',
        );

        debugPrint(
          'LOGIN USER ROLE: $role',
        );

        // ======================================================
        // PROVIDER STATE MANAGEMENT
        // ======================================================
        //
        // Store normal user's login information globally.
        // Admin does not need UserProvider here.
        //

        if (role != 'admin') {
          context.read<UserProvider>().setUser(
            userId: userId,
            userName: userName,
            email: user['email']?.toString() ?? email,
          );

          debugPrint(
            'PROVIDER USER NAME: ${context.read<UserProvider>().userName}',
          );

          debugPrint(
            'PROVIDER USER EMAIL: ${context.read<UserProvider>().email}',
          );
        }

        setState(() {
          isLoading = false;
        });

        // ======================================================
        // ADMIN
        // ======================================================

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AdminDashboardScreen(
                userId: userId,
                userName: userName,
              ),
            ),
          );
        }

        // ======================================================
        // NORMAL USER
        // ======================================================

        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DashboardScreen(
                userId: userId,
                userName: userName,
              ),
            ),
          );
        }
      }

      // ========================================================
      // LOGIN FAILED
      // ========================================================

      else {
        setState(() {
          isLoading = false;
        });

        showMessage(
          'Incorrect email or password.',
          Colors.red,
        );
      }
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint(
        'LOGIN ERROR: $e',
      );

      showMessage(
        'Login failed. Please try again.',
        Colors.red,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        duration:
            const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: Colors.green.shade700,
      ),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor:
          const Color(0xFFF7FAF8),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide(
          color: Colors.grey.shade200,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide(
          color: Colors.green.shade700,
          width: 2,
        ),
      ),

      hintStyle: TextStyle(
        color: Colors.grey.shade400,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F7F3),

      body: Stack(
        children: [

          // ======================================================
          // BACKGROUND DECORATION
          // ======================================================

          Positioned(
            top: -100,
            right: -80,

            child: Container(
              width: 280,
              height: 280,

              decoration:
                  BoxDecoration(
                color:
                    Colors.green.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,

            child: Container(
              width: 300,
              height: 300,

              decoration:
                  BoxDecoration(
                color:
                    Colors.green.withValues(
                  alpha: 0.06,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================

          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),

              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 450,
                ),

                child: Container(
                  padding:
                      const EdgeInsets.fromLTRB(
                    34,
                    36,
                    34,
                    28,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(
                          alpha: 0.08,
                        ),
                        blurRadius: 30,
                        offset:
                            const Offset(0, 12),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      // ==================================================
                      // LOGO
                      // ==================================================

                      Container(
                        width: 86,
                        height: 86,

                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            colors: [
                              Colors.green.shade700,
                              Colors.green.shade500,
                            ],
                          ),

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
                          size: 48,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // APP NAME
                      // ==================================================

                      Text(
                        'WasteCare',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Colors.green.shade800,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Smart waste reporting for cleaner communities',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // WELCOME
                      // ==================================================

                      const Align(
                        alignment:
                            Alignment.centerLeft,

                        child: Text(
                          'Welcome back 👋',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFF1F2937),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Align(
                        alignment:
                            Alignment.centerLeft,

                        child: Text(
                          'Sign in to continue to your account',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // EMAIL
                      // ==================================================

                      _fieldLabel(
                        'Email Address',
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller:
                            emailController,

                        keyboardType:
                            TextInputType.emailAddress,

                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            inputDecoration(
                          hint:
                              'Enter your email',
                          icon:
                              Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // PASSWORD
                      // ==================================================

                      _fieldLabel(
                        'Password',
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller:
                            passwordController,

                        obscureText:
                            obscurePassword,

                        textInputAction:
                            TextInputAction.done,

                        onSubmitted: (_) {
                          if (!isLoading) {
                            loginUser();
                          }
                        },

                        decoration:
                            inputDecoration(
                          hint:
                              'Enter your password',
                          icon:
                              Icons.lock_outline,

                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },

                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // LOGIN BUTTON
                      // ==================================================

                      SizedBox(
                        width:
                            double.infinity,
                        height: 54,

                        child:
                            ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : loginUser,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green.shade700,

                            disabledBackgroundColor:
                                Colors.green.shade300,

                            foregroundColor:
                                Colors.white,

                            elevation: 3,

                            shadowColor:
                                Colors.green.withValues(
                              alpha: 0.25,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),

                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,

                                  child:
                                      CircularProgressIndicator(
                                    color:
                                        Colors.white,
                                    strokeWidth:
                                        2.5,
                                  ),
                                )

                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,

                                  children: [
                                    Text(
                                      'Login',
                                      style:
                                          TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(
                                      width: 8,
                                    ),

                                    Icon(
                                      Icons
                                          .arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // DIVIDER
                      // ==================================================

                      Row(
                        children: [

                          Expanded(
                            child:
                                Divider(
                              color:
                                  Colors.grey.shade200,
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),

                            child: Text(
                              'OR',
                              style:
                                  TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    Colors.grey.shade500,
                              ),
                            ),
                          ),

                          Expanded(
                            child:
                                Divider(
                              color:
                                  Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // CREATE ACCOUNT
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Text(
                            "Don't have an account?",
                            style:
                                TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),

                          TextButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const RegisterScreen(),
                                          ),
                                        );
                                      },

                            child: Text(
                              'Create Account',
                              style:
                                  TextStyle(
                                color:
                                    Colors.green.shade700,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // FOOTER
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Icon(
                            Icons.eco_outlined,
                            size: 15,
                            color:
                                Colors.green.shade600,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            'Together for a cleaner environment',
                            style:
                                TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.grey.shade500,
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
        ],
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(String text) {
    return Align(
      alignment:
          Alignment.centerLeft,

      child: Text(
        text,

        style: TextStyle(
          fontSize: 13,
          fontWeight:
              FontWeight.w600,
          color:
              Colors.grey.shade700,
        ),
      ),
    );
  }
}