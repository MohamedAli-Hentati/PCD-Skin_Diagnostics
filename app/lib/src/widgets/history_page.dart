import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const labels = [
  'Basal Cell Carcinoma',
  'Melanoma',
  'Acne',
  'Folliculitis',
  'Pityriasis Rubra Pilaris',
  'Erythema',
  'Squamous Cell Carcinoma',
  'Porokeratosis Actinic',
  'Pityriasis Rosea',
  'Hailey Hailey Disease',
  'Granuloma Annulare',
  'Prurigo Nodularis'
];

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final labelId = document['label_id'] as int;
                final confidence = document['confidence'] as double;
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
                  title: Text('Result: ${labels[labelId]} with ${(confidence * 100).toStringAsFixed(2)}% certainty'),
                  subtitle: Text('Date: ${date.toDate()}'),
                );
              },
            );
          },
        ));
  }
}
