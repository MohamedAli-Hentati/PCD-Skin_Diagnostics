import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/src/utils/color_utils.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  ChatBotPageState createState() => ChatBotPageState();
}

class ChatBotPageState extends State<ChatBotPage> {
  final messageController = TextEditingController();
  late final HttpClient client;
  List<dynamic> conversation = [];
  bool isLoading = true;
  bool error = false;

  ChatBotPageState() {
    final securityContext = SecurityContext();
    rootBundle.load('lib/assets/certificates/certificate.pem').then((bytes) {
      securityContext.setTrustedCertificatesBytes(bytes.buffer.asUint8List());
      client = HttpClient(context: securityContext);
      client.connectionTimeout = const Duration(seconds: 10);
    });
  }

  @override
  void initState() {
    super.initState();
    getConversation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getConversation() async {
    try {
      setState(() {
        isLoading = true;
      });
      final token = await FirebaseAuth.instance.currentUser!.getIdToken();
      final request = await client.getUrl(Uri.parse('https://skindiagnostics.ddns.net/chatbot/getConversation'));
      request.headers.set('token', token!);
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final jsonString = await response.transform(utf8.decoder).join();
        setState(() {
          conversation = jsonDecode(jsonString) as List<dynamic>;
          isLoading = false;
          error = false;
        });
        if (conversation.isEmpty) {
          generateResponse();
        }
      } else {
        setState(() {
          isLoading = false;
          error = true;
        });
      }
    } on Exception {
      setState(() {
        isLoading = false;
        error = true;
      });
    }
  }

  Future<void> generateResponse() async {
    try {
      final token = await FirebaseAuth.instance.currentUser!.getIdToken();
      final request = await client.getUrl(Uri.parse('https://skindiagnostics.ddns.net/chatbot/generateResponse'));
      request.headers.set('token', token!);
      final response = await request.close();
      if (response.statusCode == 200) {
        conversation.add({'role': 'assistant', 'content': ''});
        await for (var text in response.transform(utf8.decoder)) {
          setState(() {
            conversation.last['content'] += text;
          });
        }
      } else {
        setState(() {
          error = true;
        });
      }
    } on Exception {
      setState(() {
        error = true;
      });
    }
  }

  Future<void> deleteConversation() async {
    try {
      final token = await FirebaseAuth.instance.currentUser!.getIdToken();
      final request = await client.deleteUrl(Uri.parse('https://skindiagnostics.ddns.net/chatbot/deleteConversation'));
      request.headers.set('token', token!);
      final response = await request.close();
      if (response.statusCode != 200) {
        setState(() {
          error = true;
        });
      }
    } on Exception {
      setState(() {
        error = true;
      });
    }
  }

  Future<void> addMessage(String? message) async {
    try {
      if (message != null && message.isNotEmpty) {
        final token = await FirebaseAuth.instance.currentUser!.getIdToken();
        final request = await client.postUrl(Uri.parse('https://skindiagnostics.ddns.net/chatbot/addMessage'));
        request.headers.set('token', token!);
        request.headers.set('message', message);
        final response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          setState(() {
            conversation.add({'role': 'user', 'content': message});
          });
          generateResponse();
        } else {
          setState(() {
            error = true;
          });
        }
      }
    } on Exception {
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.grey,
        title: const Text('Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: getConversation,
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: Builder(
              builder: (context) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (error) {
                  return const Center(child: Text('An error has occurred, please reload the page.'));
                } else {
                  return ListView.builder(
                    reverse: true,
                    itemCount: conversation.length,
                    itemBuilder: (context, index) {
                      index = conversation.length - 1 - index;
                      if (conversation[index]['role'] == 'user') {
                        return Container(
                          margin: const EdgeInsets.only(right: 20, left: 75, top: 10, bottom: 10),
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(12.5),
                            decoration: BoxDecoration(
                              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
                              color: darken(Theme.of(context).colorScheme.surface, percentage: 0.01),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              conversation[index]['content'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.only(right: 75, left: 20, top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12.5),
                            decoration: BoxDecoration(
                              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              conversation[index]['content'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 5)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.add_comment_outlined),
                    onPressed: () async {
                      if (!error) {
                        await deleteConversation();
                        getConversation();
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        hintText: 'Ask a question...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      controller: messageController,
                      onSubmitted: (message) {
                        if (!error) {
                          addMessage(messageController.text);
                          messageController.clear();
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (!error) {
                        addMessage(messageController.text);
                        messageController.clear();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
