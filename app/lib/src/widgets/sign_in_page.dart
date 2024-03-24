import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignInPage extends StatefulWidget {
  final Function()? onSignUpTap;
  final Function()? onForgotPasswordTap;
  const SignInPage(
      {super.key, required this.onSignUpTap, this.onForgotPasswordTap});
  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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

  Future<void> signInWithPassword() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        User? user = FirebaseAuth.instance.currentUser;
        await FirebaseAuth.instance.signOut();
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
                  TextButton(
                      onPressed: () async {
                        await user?.sendEmailVerification();
                        Navigator.pop(context);
                        showDialogMessage(
                            'A verification email has been sent to: ${user?.email}');
                      },
                      child: Text('Resend email')),
                ],
                title: Text('Account not verified, please check your email.'),
              ));
            });
      }
    } on FirebaseAuthException catch (exception) {
      Navigator.pop(context);
      switch (exception.code) {
        case 'channel-error':
          showDialogMessage(
              'Missing credentials, please type both email and password.');
        case 'invalid-credential':
          showDialogMessage(
              'Invalid credentials, please check your email and password and try again.');
        case 'invalid-email':
          showDialogMessage(
              'Invalid email, please check your email and try again.');
        case 'too-many-requests':
          showDialogMessage('A problem occurred, please try again later.');
        default:
          showDialogMessage('Sorry, an error has occurred.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (exception) {
      showDialogMessage('Sorry, an error has occurred.');
    }
  }

  Future<void> signInWithFacebook() async {
    //try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    //} on Exception catch (exception) {
    //  showDialogMessage('Sorry, an error has occurred.');
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sign In')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(size: 100),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Text(
                        'It appears that you are signed off, Please sign in:'),
                  ),
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
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: widget.onForgotPasswordTap,
                            child: Text('Forgot password?',
                                style: TextStyle(
                                    decoration: TextDecoration.underline))),
                      ],
                    ),
                  ),
                  Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      child: Text('Sign in'),
                      style: ButtonStyle(),
                      onPressed: signInWithPassword,
                    ),
                  )),
                  Padding(
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
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: signInWithGoogle,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              boxShadow: [BoxShadow(blurRadius: 5)],
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
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: signInWithFacebook,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              boxShadow: [BoxShadow(blurRadius: 5)],
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      SizedBox(width: 5),
                      GestureDetector(
                          onTap: widget.onSignUpTap,
                          child: Text('Sign up!',
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
