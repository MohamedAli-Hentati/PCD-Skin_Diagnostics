import 'package:flutter/material.dart';
import 'package:app/src/widgets/sign_in_screen.dart';
import 'package:app/src/widgets/sign_up_screen.dart';
import 'package:app/src/widgets/forgot_password_screen.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});
  @override
  State<SignScreen> createState() => SignScreenState();
}

class SignScreenState extends State<SignScreen> {
  int currentScreenIndex = 0;
  void showSignInScreen() {
    setState(() {
      currentScreenIndex = 0;
    });
  }

  void showSignUpScreen() {
    setState(() {
      currentScreenIndex = 1;
    });
  }

  void showForgotPasswordScreen() {
    setState(() {
      currentScreenIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentScreenIndex) {
      case 1:
        return SignUpScreen(onSignInTap: showSignInScreen);
      case 2:
        return ForgotPasswordScreen();
      default:
        return SignInScreen(
            onSignUpTap: showSignUpScreen,
            onForgotPasswordTap: showForgotPasswordScreen);
    }
  }
}
