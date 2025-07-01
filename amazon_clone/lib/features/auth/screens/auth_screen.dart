import 'package:amazon_clone/common/widgets/custom_button.dart';
import 'package:amazon_clone/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:amazon_clone/common/widgets/custom_textfield.dart';

enum Auth {
  signUp,
  signIn,
}

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
} 

class _AuthScreenState extends State<AuthScreen> {
  Auth _auth = Auth.signUp;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _nameController = TextEditingController();

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  _nameController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.greyBackgroundCOlor,
      body: SafeArea( 
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  ),
                ),
              ListTile(
                tileColor: _auth == Auth.signUp
                    ? GlobalVariables.backgroundColor
                    : GlobalVariables.greyBackgroundCOlor,
                title: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              leading: Radio(
                activeColor: GlobalVariables.secondaryColor,
                value: Auth.signUp,
                groupValue: _auth,
                onChanged: (Auth? val) {
                  setState(() {
                    _auth = val!;
                  });
                },
                ),
              ),
              if(_auth == Auth.signUp)
               Container(
                padding: const EdgeInsets.all(8.0),
                color: GlobalVariables.backgroundColor,
                 child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController, 
                        hintText: 'Name',
                        ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _emailController, 
                        hintText: 'Email',
                        ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _passwordController,    
                        hintText: 'Password',
                        ),
                    const SizedBox(height: 10),
                      CustomButton(
                        text: 'Sign Up',
                        onTap: () {},
                      )
                    ],
                  ),
                 ),
               ),
              ListTile(
                tileColor: _auth == Auth.signIn
                    ? GlobalVariables.backgroundColor
                    : GlobalVariables.greyBackgroundCOlor,
                title: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              leading: Radio(
                activeColor: GlobalVariables.secondaryColor,
                value: Auth.signIn,
                groupValue: _auth,
                onChanged: (Auth? val) {
                  setState(() {
                    _auth = val!;
                  });
                },
                ),
              ),
              if(_auth == Auth.signIn)
               Container(
                padding: const EdgeInsets.all(8.0),
                color: GlobalVariables.backgroundColor,
                 child: Form(
                  key: _signInFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController, 
                        hintText: 'Email',
                        ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _passwordController,    
                        hintText: 'Password',
                        ),
                    const SizedBox(height: 10),
                      CustomButton(
                        text: 'Sign In',
                        onTap: () {},
                      )
                    ],
                  ),
                 ),
               ),
            ],
          ),  
        ),
        )
    );
  }
}