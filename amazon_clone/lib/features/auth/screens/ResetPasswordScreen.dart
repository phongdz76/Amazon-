import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/reset-password';
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await authService.resetPassword(
        context: context,
        email: widget.email,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );

      if (success) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showSnackBar('Có lỗi xảy ra: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              const Text('Success!'),
            ],
          ),
          content: const Text(
            'Your password has been reset successfully. You can now login with your new password.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(
                  context,
                ).popUntil((route) => route.isFirst); // Về màn hình đầu
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: GlobalVariables.selectedNavBarColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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

            const Text(
              'Create New Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              'Create a secure password for',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            Text(
              widget.email,
              style: TextStyle(
                fontSize: 16,
                color: GlobalVariables.selectedNavBarColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Password Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 30),
                  _buildResetButton(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Password requirements
            _buildPasswordRequirements(),

            const SizedBox(height: 20),

            // Security info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your new password will be encrypted and stored securely',
                      style: TextStyle(color: Colors.green[700], fontSize: 14),
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

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'Enter new password',
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: _validatePassword,
        onChanged: (value) {
          // Trigger form validation when password changes
          if (_confirmPasswordController.text.isNotEmpty) {
            _formKey.currentState?.validate();
          }
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          hintText: 'Confirm new password',
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: _validateConfirmPassword,
        onFieldSubmitted: (_) => _resetPassword(),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
              const SizedBox(width: 8),
              Text(
                'Password Requirements',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('At least 6 characters long'),
          _buildRequirementItem('Contains at least one letter'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[600], fontSize: 12),
            ),
          ),
        ],
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
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
