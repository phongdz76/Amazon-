import 'package:amazon_clone/constants/global_variables.dart';
import 'package:amazon_clone/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:amazon_clone/common/widgets/custom_textfield.dart';

enum Auth { signUp, signIn }

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  Auth _auth = Auth.signUp;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void signUpUser() {
    authService.signUpUser(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );
  }

  void signInUser() {
    authService.signInUser(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.7, 1.0],
            colors: [
              const Color(0xFF232F3E), // Amazon dark blue
              GlobalVariables.selectedNavBarColor,
              const Color(0xFF00A8CC), // Teal blue
              const Color(0xFFFF9500), // Amazon orange
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo and Welcome Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_rounded,
                            size: 80,
                            color: GlobalVariables.selectedNavBarColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome to Amazon Clone',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: GlobalVariables.selectedNavBarColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in to continue shopping',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Auth Toggle Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _auth = Auth.signUp;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: _auth == Auth.signUp
                                      ? LinearGradient(
                                          colors: [
                                            GlobalVariables.selectedNavBarColor,
                                            GlobalVariables.selectedNavBarColor
                                                .withOpacity(0.8),
                                          ],
                                        )
                                      : null,
                                  color: _auth == Auth.signUp
                                      ? null
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: _auth == Auth.signUp
                                      ? [
                                          BoxShadow(
                                            color: GlobalVariables
                                                .selectedNavBarColor
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _auth == Auth.signUp
                                        ? Colors.white
                                        : GlobalVariables.selectedNavBarColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _auth = Auth.signIn;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: _auth == Auth.signIn
                                      ? LinearGradient(
                                          colors: [
                                            GlobalVariables.selectedNavBarColor,
                                            GlobalVariables.selectedNavBarColor
                                                .withOpacity(0.8),
                                          ],
                                        )
                                      : null,
                                  color: _auth == Auth.signIn
                                      ? null
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: _auth == Auth.signIn
                                      ? [
                                          BoxShadow(
                                            color: GlobalVariables
                                                .selectedNavBarColor
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _auth == Auth.signIn
                                        ? Colors.white
                                        : GlobalVariables.selectedNavBarColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Forms
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _auth == Auth.signUp
                          ? _buildSignUpForm()
                          : _buildSignInForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      key: const ValueKey('signUp'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Password',
              isPassword: true,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_signUpFormKey.currentState!.validate()) {
                    signUpUser();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.selectedNavBarColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: GlobalVariables.selectedNavBarColor.withOpacity(
                    0.4,
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Container(
      key: const ValueKey('signIn'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _signInFormKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Password',
              isPassword: true,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_signInFormKey.currentState!.validate()) {
                    signInUser();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.selectedNavBarColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: GlobalVariables.selectedNavBarColor.withOpacity(
                    0.4,
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: GlobalVariables.selectedNavBarColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
