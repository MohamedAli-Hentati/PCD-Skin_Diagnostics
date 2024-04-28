import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  PrivacyPageState createState() => PrivacyPageState();
}

class PrivacyPageState extends State<PrivacyPage> {
  List<Item> data = generateItems(6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, right: 25, left: 25),
        child: ListView(
          children: data.map<Widget>((Item item) {
            return ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(item.headerValue),
                    );
                  },
                  body: ListTile(
                    title: Text(item.expandedValue),
                  ),
                  isExpanded: item.isExpanded,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      headerValue: headerItems[index],
      expandedValue: expandedItems[index],
    );
  });
}

const headerItems = <String>[
  'Personal Information',
  'Skin Scan History',
  'Data Deletion',
  'Data Usage',
  'Third-Party Services',
  'User Rights',
];

const expandedItems = <String>[
  'We value your privacy. In our app, you have the option to provide personal information. This information helps our chatbot understand you better and provide more accurate responses. Rest assured, this data is used solely to improve your experience with our service.',
  'Our app has a feature that stores your skin scan history. This allows you to track changes over time and helps us provide personalized skin care advice. Your skin scan history is private and only visible to you.',
  'We respect your right to control your data. If you decide to delete your account, all your data including personal information and skin scan history will be permanently deleted from our servers. We do not sell or use your data for our gain.',
  'We use the collected data for various purposes: to provide and maintain our Service, to notify you about changes to our Service, to allow you to participate in interactive features of our Service when you choose to do so, to provide customer support, to gather analysis or valuable information so that we can improve our Service, to monitor the usage of our Service, to detect, prevent and address technical issues.',
  'We may employ third party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used. These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.',
  'If you are a resident of the European Economic Area (EEA), you have certain data protection rights. We aim to take reasonable steps to allow you to correct, amend, delete, or limit the use of your Personal Data. If you wish to be informed what Personal Data we hold about you and if you want it to be removed from our systems, please contact us.',
];