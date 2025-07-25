import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await authService.sendResetOTP(
        context: context,
        email: _emailController.text.trim(),
      );

      if (success) {
        // Chuyển sang màn hình OTP
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: _emailController.text.trim(),
        );
      }
    } catch (e) {
      _showSnackBar('Có lỗi xảy ra: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeProvider.isDarkMode
                      ? const Color(0xFF1A1A1A)
                      : GlobalVariables.selectedNavBarColor,
                  themeProvider.isDarkMode
                      ? const Color(0xFF2D2D2D)
                      : GlobalVariables.selectedNavBarColor.withOpacity(0.8),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 60),
                      _buildContentCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Icon và title
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GlobalVariables.selectedNavBarColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.lock_reset,
                size: 40,
                color: GlobalVariables.selectedNavBarColor,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Forgot Your Password?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              'Enter your email address and we\'ll send you a verification code to reset your password.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Email form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildEmailField(),
                  const SizedBox(height: 30),
                  _buildResetButton(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Back to sign in
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: GlobalVariables.selectedNavBarColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: GlobalVariables.selectedNavBarColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Info container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'We\'ll send a 6-digit verification code to your email address',
                      style: TextStyle(color: Colors.blue[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email address';
          }
          if (!value.contains('@') || !value.contains('.')) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlobalVariables.selectedNavBarColor,
            GlobalVariables.selectedNavBarColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: GlobalVariables.selectedNavBarColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : _resetPassword,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Send Verification Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
