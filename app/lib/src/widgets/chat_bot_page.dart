import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  ChatBotPageState createState() => ChatBotPageState();
}

class ChatBotPageState extends State<ChatBotPage> {
  late final HttpClient client;
  final messageController = TextEditingController();
  var response = '';

  ChatBotPageState() {
    final securityContext = SecurityContext();
    rootBundle.load('lib/assets/certificates/certificate.pem').then((bytes) {
      securityContext.setTrustedCertificatesBytes(bytes.buffer.asUint8List());
      client = HttpClient(context: securityContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(hintText: 'Message'),
              ),
            ),
            const SizedBox(height: 50),
            Text('Response: $response'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final token = await FirebaseAuth.instance.currentUser!.getIdToken();
          final request = await client.getUrl(Uri.parse('https://skindiagnostics.ddns.net/chatbot'));
          request.headers.set('token', token!);
          request.headers.set('message', messageController.text);
          final result = await request.close();
          if (result.statusCode == 200) {
            final body = await result.transform(utf8.decoder).join();
            setState(() {
              response = body;
            });
          }
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
