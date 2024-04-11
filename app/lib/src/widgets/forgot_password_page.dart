import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
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
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Close')),
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
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      Navigator.of(context, rootNavigator: true).pop();
      showDialogMessage('A verification code has been sent to: ${emailController.text}');
    } on FirebaseAuthException catch (exception) {
      Navigator.of(context, rootNavigator: true).pop();
      switch (exception.code) {
        case 'channel-error':
          showDialogMessage('Missing email, please type the email in the text field.');
        case 'invalid-email':
          showDialogMessage('Invalid email, please check your email and try again.');
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
