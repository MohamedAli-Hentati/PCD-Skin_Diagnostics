import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('History'),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('history')
                  .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading history'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No history available'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];
                    final date = document['date'] as Timestamp;
                    final imageUrl = document['image_url'] as String;
                    final result = document['result'] as String;

                    return ListTile(
                      leading: Image.network(imageUrl),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            content: Image.network(imageUrl),
                          ),
                        );
                      },
                      title: Text('Result: $result'),
                      subtitle: Text('Date: ${date.toDate()}'),
                    );
                  },
                );
              },
            )));
  }
}
