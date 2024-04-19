import 'package:flutter/material.dart';
import 'package:app/src/widgets/sign_up_page.dart';
import 'package:app/src/widgets/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:app/src/utils/color_utils.dart';
import 'package:app/src/components/dialog_components.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signInWithPassword() {
    showProgressionDialog(context: context);
    FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((value) {
      Navigator.of(context, rootNavigator: true).pop();
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return Center(
                  child: AlertDialog(
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text('Close')),
                  TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
                          Navigator.of(context, rootNavigator: true).pop();
                          showMessageDialog(
                              context: context,
                              message: 'A verification email has been sent to: ${FirebaseAuth.instance.currentUser!.email}');
                          FirebaseAuth.instance.signOut();
                        }).catchError((exception) {
                          Navigator.of(context, rootNavigator: true).pop();
                          showMessageDialog(context: context, message: 'A problem occurred, please try again later.');
                        });
                      },
                      child: const Text('Resend email')),
                ],
                title: const Text('Account not verified, please check your email.'),
              ));
            });
      }
    }).catchError((exception) {
      Navigator.of(context, rootNavigator: true).pop();
      switch (exception.code) {
        case 'channel-error':
          showMessageDialog(context: context, message: 'Missing credentials, please type both email and password.');
        case 'invalid-credential':
          showMessageDialog(context: context, message: 'Invalid credentials, please check your email and password and try again.');
        case 'invalid-email':
          showMessageDialog(context: context, message: 'Invalid email, please check your email and try again.');
        case 'too-many-requests':
          showMessageDialog(context: context, message: 'A problem occurred, please try again later.');
        default:
          showMessageDialog(context: context, message: 'Sorry, an error has occurred.');
      }
    });
  }

  void signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser?.authentication;
    if (googleAuth != null) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      FirebaseAuth.instance.signInWithCredential(credential).then((value) {}).catchError((exception) {
        showMessageDialog(context: context, message: 'Sorry, an error has occurred.');
      });
    }
  }

  void signInWithFacebook() async {
    final login = await FacebookAuth.instance.login();
    if (login.accessToken != null) {
      final credential = FacebookAuthProvider.credential(login.accessToken!.token);
      FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        if (!FirebaseAuth.instance.currentUser!.emailVerified) {
          FirebaseAuth.instance.currentUser?.sendEmailVerification().then((value) {
            showMessageDialog(
                context: context, message: 'A verification email has been sent to: ${FirebaseAuth.instance.currentUser?.email}');
            FirebaseAuth.instance.signOut();
          });
        }
      }).catchError((exception) {
        showMessageDialog(context: context, message: 'Sorry, an error has occurred.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 100),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Text('It appears that you are signed off'),
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                        },
                        child: Text('Forgot password?',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ))),
                  ],
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextButton(
                  style: const ButtonStyle(),
                  onPressed: signInWithPassword,
                  child: const Text('Sign in'),
                ),
              )),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Row(
                  children: [
                    Expanded(child: Divider(thickness: 2)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Or continue with'),
                    ),
                    Expanded(child: Divider(thickness: 2)),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: signInWithGoogle,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                          boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 5)],
                          borderRadius: BorderRadius.circular(5)),
                      child: Image.asset(
                        'lib/assets/images/google.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: signInWithFacebook,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                          boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 5)],
                          borderRadius: BorderRadius.circular(5)),
                      child: Image.asset(
                        'lib/assets/images/facebook.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
                      },
                      child: Text('Sign up!',
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
    );
  }
}
