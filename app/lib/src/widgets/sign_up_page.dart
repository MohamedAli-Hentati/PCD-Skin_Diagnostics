import 'package:flutter/material.dart';
import 'package:app/src/components/dialog_components.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signUpWithPassword() async {
    if (usernameController.text == '' ||
        emailController.text == '' ||
        passwordController.text == '' ||
        confirmPasswordController.text == '') {
      showMessageDialog(context: context, message: 'Missing fields, please fill out all of the text fields.');
    } else if (passwordController.text != confirmPasswordController.text) {
      showMessageDialog(context: context, message: 'Passwords do not match.');
    } else {
      showProgressionDialog(context: context);
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        await FirebaseAuth.instance.currentUser!.updateDisplayName(usernameController.text);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
        showMessageDialog(context: context, message: 'A verification email has been sent to: ${emailController.text}');
      } on FirebaseAuthException catch (exception) {
        Navigator.of(context, rootNavigator: true).pop();
        switch (exception.code) {
          case 'weak-password':
            showMessageDialog(context: context, message: 'Please choose a stronger password.');
          case 'email-already-in-use':
            showMessageDialog(context: context, message: 'An account already exists with this email address.');
          case 'invalid-email':
            showMessageDialog(context: context, message: 'Invalid email, please check your email and try again.');
          case 'too-many-requests':
            showMessageDialog(context: context, message: 'A problem occurred, Please try again later.');
          default:
            showMessageDialog(context: context, message: 'Sorry, something went wrong.');
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
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(hintText: 'Username'),
                    ),
                  ),
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
                            Navigator.pop(context);
                          },
                          child: Text('Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              )))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
