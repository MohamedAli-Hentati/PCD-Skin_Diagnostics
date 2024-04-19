import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/src/components/dialog_components.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  void confirm() {
    showProgressionDialog(context: context);
    FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text).then((value) {
      Navigator.of(context, rootNavigator: true).pop();
      showMessageDialog(context: context, message: 'A password reset email has been sent to: ${emailController.text}');
    }).catchError((exception) {
      Navigator.of(context, rootNavigator: true).pop();
      switch (exception.code) {
        case 'channel-error':
          showMessageDialog(context: context, message: 'Missing email, please type the email in the text field.');
        case 'invalid-email':
          showMessageDialog(context: context, message: 'Invalid email, please check your email and try again.');
        case 'too-many-requests':
          showMessageDialog(context: context, message: 'A problem occurred, Please try again later.');
        default:
          showMessageDialog(context: context, message: 'Sorry, an error has occurred.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 100),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text('Send a password reset email:'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextButton(
                  style: const ButtonStyle(),
                  onPressed: confirm,
                  child: const Text('Send'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
