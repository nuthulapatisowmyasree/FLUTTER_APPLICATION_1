import 'package:flutter/material.dart';

import '../database_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> registerUser() async {

    final fullName =
        fullNameController.text.trim();

    final email =
        emailController.text.trim().toLowerCase();

    final phone =
        phoneController.text.trim();

    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    // ==========================================================
    // EMPTY FIELD VALIDATION
    // ==========================================================

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {

      showMessage(
        'Please fill in all fields.',
        Colors.red,
      );

      return;
    }

    // ==========================================================
    // EMAIL VALIDATION
    // ==========================================================

    if (!RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    ).hasMatch(email)) {

      showMessage(
        'Please enter a valid email address.',
        Colors.red,
      );

      return;
    }

    // ==========================================================
    // PHONE VALIDATION
    // ==========================================================

    if (phone.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phone)) {

      showMessage(
        'Please enter a valid 10-digit phone number.',
        Colors.red,
      );

      return;
    }

    // ==========================================================
    // PASSWORD VALIDATION
    // ==========================================================

    if (password.length < 6) {

      showMessage(
        'Password must contain at least 6 characters.',
        Colors.red,
      );

      return;
    }

    // ==========================================================
    // CONFIRM PASSWORD
    // ==========================================================

    if (password != confirmPassword) {

      showMessage(
        'Passwords do not match.',
        Colors.red,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // ========================================================
      // CHECK EXISTING EMAIL IN SQLITE
      // ========================================================

      final exists =
          await DatabaseHelper.instance
              .emailExists(email);

      if (exists) {

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        showMessage(
          'This email is already registered. Please login.',
          Colors.red,
        );

        return;
      }

      // ========================================================
      // INSERT USER INTO SQLITE
      // ========================================================

      await DatabaseHelper.instance.insertUser({

        'fullName': fullName,

        'email': email,

        'phone': phone,

        'password': password,

        // Normal registered users
        // always have user role.
        'role': 'user',
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ========================================================
      // GO DIRECTLY TO LOGIN PAGE
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            successMessage:
                'Account created successfully! Please login.',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint(
        'REGISTRATION ERROR: $e',
      );

      showMessage(
        'Registration failed. Please try again.',
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

    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

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
          // BACKGROUND CIRCLES
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
                  maxWidth: 470,
                ),

                child: Container(

                  padding:
                      const EdgeInsets.fromLTRB(
                    34,
                    32,
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
                        width: 78,
                        height: 78,

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
                          size: 42,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Colors.green.shade800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Join WasteCare and help build cleaner communities',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // FULL NAME
                      // ==================================================

                      _fieldLabel('Full Name'),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                            fullNameController,

                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            inputDecoration(
                          hint:
                              'Enter your full name',
                          icon:
                              Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==================================================
                      // EMAIL
                      // ==================================================

                      _fieldLabel('Email Address'),

                      const SizedBox(height: 7),

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

                      const SizedBox(height: 17),

                      // ==================================================
                      // PHONE
                      // ==================================================

                      _fieldLabel('Phone Number'),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                            phoneController,

                        keyboardType:
                            TextInputType.phone,

                        maxLength: 10,

                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            inputDecoration(
                          hint:
                              'Enter 10-digit phone number',
                          icon:
                              Icons.phone_outlined,
                        ).copyWith(
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==================================================
                      // PASSWORD
                      // ==================================================

                      _fieldLabel('Password'),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                            passwordController,

                        obscureText:
                            obscurePassword,

                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            inputDecoration(
                          hint:
                              'Create a password',
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

                      const SizedBox(height: 17),

                      // ==================================================
                      // CONFIRM PASSWORD
                      // ==================================================

                      _fieldLabel(
                        'Confirm Password',
                      ),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                            confirmPasswordController,

                        obscureText:
                            obscureConfirmPassword,

                        textInputAction:
                            TextInputAction.done,

                        onSubmitted: (_) {
                          if (!isLoading) {
                            registerUser();
                          }
                        },

                        decoration:
                            inputDecoration(
                          hint:
                              'Re-enter your password',
                          icon:
                              Icons.lock_reset_outlined,
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },

                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ==================================================
                      // REGISTER BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 54,

                        child: ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : registerUser,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green.shade700,

                            disabledBackgroundColor:
                                Colors.green.shade300,

                            foregroundColor:
                                Colors.white,

                            elevation: 3,

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
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(width: 8),

                                    Icon(
                                      Icons
                                          .arrow_forward_rounded,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // LOGIN LINK
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Text(
                            'Already have an account?',
                            style: TextStyle(
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
                                        Navigator.pop(
                                          context,
                                        );
                                      },

                            child: Text(
                              'Login',
                              style: TextStyle(
                                color:
                                    Colors.green.shade700,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

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
                            style: TextStyle(
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
      alignment: Alignment.centerLeft,

      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}