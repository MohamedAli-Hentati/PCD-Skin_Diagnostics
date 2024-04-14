import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/utils/color_utils.dart';

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

const labelURLs = [
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com',
  'https://www.google.com'
];

class ResultPage extends StatelessWidget {
  final int labelId;
  final double confidence;
  final String imagePath;
  const ResultPage({super.key, required this.labelId, required this.confidence, required this.imagePath});

  Future<void> feedback() async {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: Column(children: [
          const SizedBox(height: 50),
          Center(
              child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 20, color: Colors.grey.shade600)],
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                width: 225,
                height: 225,
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          )),
          const SizedBox(height: 75),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  const Text('Result*:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    child: Text(labels[labelId],
                        style: TextStyle(fontSize: 15, color: theme.colorScheme.tertiary)),
                    onTap: () async {
                      await launchUrl(Uri.parse(labelURLs[labelId]));
                    },
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    child: Icon(Icons.info, size: 17, color: theme.colorScheme.tertiary),
                    onTap: () async {
                      await launchUrl(Uri.parse(labelURLs[labelId]));
                    },
                  )
                ],
              ),
              Row(children: [
                const Text('Confidence:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Text('${(confidence * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 15))
              ]),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: const [
                    TextSpan(text: 'Description: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                    tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                    leading: const Icon(Icons.feedback_outlined),
                    trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                    title: const Text('Feedback'),
                    onTap: feedback,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
              )
            ]),
          ),
        ]));
  }
}
