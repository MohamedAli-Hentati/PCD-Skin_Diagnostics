import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  final Function()? onSignInTap;
  final Function()? onSignUpTap;
  const ForgotPasswordPage(
      {super.key, required this.onSignInTap, this.onSignUpTap});
  @override
  State<ForgotPasswordPage> createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  void showDialogMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close')),
            ],
            title: Text(message),
          ));
        });
  }

  Future<void> confirm() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      Navigator.pop(context);
      showDialogMessage(
          'A verification code has been sent to: ${emailController.text}');
    } on FirebaseAuthException catch (exception) {
      Navigator.pop(context);
      switch (exception.code) {
        case 'channel-error':
          showDialogMessage(
              'Missing email, please type the email in the text field.');
        case 'invalid-email':
          showDialogMessage(
              'Invalid email, please check your email and try again.');
        case 'too-many-requests':
          showDialogMessage('A problem occurred, Please try again later.');
        default:
          showDialogMessage('Sorry, an error has occurred.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Change password')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 75),
                  FlutterLogo(size: 100),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Text('Send a password reset email:'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(hintText: 'Email'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      child: Text('Send'),
                      style: ButtonStyle(),
                      onPressed: confirm,
                    ),
                  )),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      SizedBox(width: 5),
                      GestureDetector(
                          onTap: widget.onSignUpTap,
                          child: Text('Sign Up',
                              style: TextStyle(
                                  decoration: TextDecoration.underline)))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
