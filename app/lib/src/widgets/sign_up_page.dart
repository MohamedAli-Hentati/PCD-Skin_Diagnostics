import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  final Function()? onSignInTap;
  const SignUpPage(
      {super.key, required this.onSignInTap});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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

  Future<void> signUpWithPassword() async {
    if (passwordController.text != confirmPasswordController.text) {
      showDialogMessage('Passwords do not match.');
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        Navigator.pop(context);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        showDialogMessage(
            'A verification email has been sent to: ${emailController.text}');
        await FirebaseAuth.instance.signOut();
        widget.onSignInTap!();
      } on FirebaseAuthException catch (exception) {
        Navigator.pop(context);
        switch (exception.code) {
          case 'weak-password':
            showDialogMessage('Please choose a stronger password.');
          case 'channel-error':
            showDialogMessage(
                'Missing credentials, please provide both email and password.');
          case 'email-already-in-use':
            showDialogMessage(
                'An account already exists with this email address.');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sign Up')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 75),
                  FlutterLogo(size: 100),
                  SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(hintText: 'Email'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(hintText: 'Password'),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(hintText: 'Confirm password'),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      child: Text('Sign up'),
                      style: ButtonStyle(),
                      onPressed: signUpWithPassword,
                    ),
                  )),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have an existing account?'),
                      SizedBox(width: 5),
                      GestureDetector(
                          onTap: widget.onSignInTap,
                          child: Text('Sign in',
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
