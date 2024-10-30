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
  'Squamous Cell Carcinoma',
  'Erythema multiforme',
  'Porokeratosis Actinic',
  'Pityriasis Rosea',
  'Hailey Hailey Disease',
  'Granuloma Annulare',
  'Prurigo Nodularis'
];

const urls = [
  'https://www.mayoclinic.org/diseases-conditions/basal-cell-carcinoma/symptoms-causes/syc-20354187',
  'https://www.mayoclinic.org/diseases-conditions/melanoma/symptoms-causes/syc-20374884',
  'https://www.mayoclinic.org/diseases-conditions/acne/symptoms-causes/syc-20368047',
  'https://my.clevelandclinic.org/health/diseases/17692-folliculitis',
  'https://www.merckmanuals.com/professional/dermatologic-disorders/psoriasis-and-scaling-diseases/pityriasis-rubra-pilaris',
  'https://www.mayoclinic.org/diseases-conditions/squamous-cell-carcinoma/symptoms-causes/syc-20352480',
  'https://en.wikipedia.org/wiki/Erythema_multiforme',
  'https://dermnetnz.org/topics/disseminated-superficial-actinic-porokeratosis',
  'https://www.mayoclinic.org/diseases-conditions/pityriasis-rosea/symptoms-causes/syc-20376405',
  'https://rarediseases.org/rare-diseases/hailey-hailey-disease/',
  'https://www.mayoclinic.org/diseases-conditions/granuloma-annulare/symptoms-causes/syc-20351319',
  'https://www.mayoclinic.org/diseases-conditions/prurigo-nodularis/symptoms-causes/syc-20376738'
];
const descriptions = [
  'A type of skin cancer that begins in the basal cells of the skin. It often appears as a pearly or waxy bump.',
  'The most serious type of skin cancer, which develops in the melanocytes, the cells that produce melanin.',
  'A common skin condition that occurs when hair follicles become clogged with oil and dead skin cells, leading to pimples, blackheads, and cysts.',
  'An inflammation or infection of the hair follicles, which can be caused by bacteria, fungi, or viruses.',
  'A rare skin disorder characterized by reddish-orange scaling patches and tiny bumps.',
  'A type of skin cancer that develops in the squamous cells, which are flat cells found in the outer layer of the skin.',
  'A skin condition that causes red, target-shaped spots or patches on the skin, often triggered by infections or medications.',
  'A skin condition characterized by small, raised bumps or patches that develop on sun-exposed skin.',
  'A common skin rash that begins with a single, large pink or tan patch, followed by smaller patches that form a pattern on the skin.',
  'A rare genetic skin disorder that causes red, scaly patches on the skin, often triggered by friction or sweating.',
  'A chronic skin condition that causes small, raised bumps to form in a ring or arc shape on the skin.',
  'A skin condition characterized by itchy nodules or bumps on the skin, which can be caused by insect bites, skin injuries, or underlying conditions.'
];

const causes = [
  'Caused by long-term exposure to ultraviolet (UV) radiation from the sun or tanning beds.',
  'Caused by DNA damage to skin cells, often from UV radiation.',
  'Caused by overproduction of oil (sebum) in the skin, clogged pores, and bacteria.',
  'Caused by damage to hair follicles, usually from shaving, friction, or blockage of the follicle.',
  'The exact cause is unknown, but it may be related to immune system dysfunction.',
  'Caused by DNA damage to skin cells, often from UV radiation.',
  'Often triggered by infections, medications, or other factors that cause an immune system reaction.',
  'The exact cause is unknown, but it may be related to sun exposure.',
  'The exact cause is unknown, but it may be related to viral infections.',
  'Caused by mutations in the ATP2C1 gene, which affects the skin\'s ability to maintain its structure.',
  'The exact cause is unknown, but it may be related to immune system dysfunction.',
  'The exact cause is unknown, but it may be related to inflammation or nerve problems.'
];

const treatments = [
  'Treatment options include surgery, radiation therapy, and topical medications.',
  'Treatment options include surgery, radiation therapy, immunotherapy, and targeted therapy.',
  'Treatment options include topical treatments (such as retinoids and benzoyl peroxide), oral medications (such as antibiotics and isotretinoin), and procedures (such as laser therapy and chemical peels).',
  'Treatment depends on the cause and may include topical or oral antibiotics, antifungal medications, or antiviral medications.',
  'Treatment may include topical corticosteroids, retinoids, or immunosuppressants.',
  'Treatment options include surgery, radiation therapy, and topical medications.',
  'Treatment may include identifying and removing the trigger, along with medications to control symptoms.',
  'Treatment may include topical treatments, cryotherapy, or photodynamic therapy.',
  'Treatment may include topical corticosteroids, antihistamines, or phototherapy.',
  'Treatment may include topical or oral medications to reduce symptoms and prevent flare-ups.',
  'Treatment options include topical corticosteroids, cryotherapy, or intralesional corticosteroid injections.',
  'Treatment may include topical treatments, oral medications, or light therapy.'
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
        body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: 'Result*: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: labels[labelId], style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.tertiary)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: 'Confidence: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: '${(confidence * 100).toStringAsFixed(2)}%', style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: 'Description: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: descriptions[labelId], style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: 'Cause: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: causes[labelId], style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: 'Treatment: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: treatments[labelId], style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                      leading: Icon(
                        Icons.feedback_outlined,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right_outlined,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      title: Text(
                        'Helpful info',
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      onTap: () async {
                        await launchUrl(Uri.parse(urls[labelId]));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                ),
              )
            ]),
          ),
        ]));
  }
}
