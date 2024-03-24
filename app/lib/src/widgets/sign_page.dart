import 'package:flutter/material.dart';
import 'package:app/src/widgets/sign_in_page.dart';
import 'package:app/src/widgets/sign_up_page.dart';
import 'package:app/src/widgets/forgot_password_page.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});
  @override
  State<SignPage> createState() => SignPageState();
}

class SignPageState extends State<SignPage> {
  int currentPageIndex = 0;
  void showSignInPage() {
    setState(() {
      currentPageIndex = 0;
    });
  }

  void showSignUpPage() {
    setState(() {
      currentPageIndex = 1;
    });
  }

  void showForgotPasswordPage() {
    setState(() {
      currentPageIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentPageIndex) {
      case 1:
        return SignUpPage(onSignInTap: showSignInPage);
      case 2:
        return ForgotPasswordPage(onSignInTap: showSignInPage, onSignUpTap: showSignUpPage);
      default:
        return SignInPage(
            onSignUpTap: showSignUpPage,
            onForgotPasswordTap: showForgotPasswordPage);
    }
  }
}
