import 'package:app/src/widgets/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Close')),
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
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        Navigator.of(context, rootNavigator: true).pop();
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        showDialogMessage('A verification email has been sent to: ${emailController.text}');
        await FirebaseAuth.instance.signOut();
        Navigator.of(context, rootNavigator: true).pop();
      } on FirebaseAuthException catch (exception) {
        Navigator.of(context, rootNavigator: true).pop();
        switch (exception.code) {
          case 'weak-password':
            showDialogMessage('Please choose a stronger password.');
          case 'channel-error':
            showDialogMessage('Missing credentials, please provide both email and password.');
          case 'email-already-in-use':
            showDialogMessage('An account already exists with this email address.');
          case 'invalid-email':
            showDialogMessage('Invalid email, please check your email and try again.');
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
        appBar: AppBar(title: const Text('Sign Up')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 75),
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(hintText: 'Confirm password'),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      style: const ButtonStyle(),
                      onPressed: signUpWithPassword,
                      child: const Text('Sign up'),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Have an existing account?'),
                      const SizedBox(width: 5),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignInPage()));
                          },
                          child: const Text('Sign in', style: TextStyle(decoration: TextDecoration.underline)))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
