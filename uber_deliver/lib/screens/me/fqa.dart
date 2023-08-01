import 'package:flutter/material.dart';

class FQAScreen extends StatelessWidget {
  final List<Map<String, String>> terms = [
    {
      'title': 'What is Bsahtek? ',
      'content':
          'Bsahtek is a mobile application that aims to reduce food waste and promote sustainability by connecting users with local restaurants, cafes, bakeries, and grocery stores. The app offers discounted "rescue meals" and surplus food items that are still fresh and delicious but would otherwise go to waste.'
    },
    {
      'title': 'How does Bsahtek work?',
      'content':
          ' Bsahtek allows users to browse nearby participating food establishments and see the available rescue meals or surplus food items. Users can then purchase these items at a significantly reduced price through the app. The purchased items can be picked up from the partnering establishment during a designated time window.'
    },
    {
      'title': 'Is Bsahtek available in my city? ',
      'content':
          'Bsahtek is continuously expanding its reach to different cities. To check if the app is available in your city, simply download the app from the App Store or Google Play Store and enter your location. If the service is available, you will be able to access all the features and participating establishments in your area.'
    },
    {
      'title': 'How can I download Bsahtek?',
      'content':
          ' Bsahtek is available for download on both the App Store (for iOS devices) and Google Play Store (for Android devices). Simply search for "Bsahtek" in the respective app store and install it like any other app.'
    },
    {
      'title': 'Is Bsahtek free to use?',
      'content':
          ' Yes, Bsahtek is free to download and use. However, keep in mind that you \'ll be purchasing rescue meals or surplus food items from local establishments at a discounted price.'
    },
    {
      'title': 'Can I choose the type of food I want? ',
      'content':
          'Yes, Bsahtek offers a variety of rescue meals and surplus food items from different partnering establishments. Users can browse through the available options and select the ones that suit their preferences and dietary requirements.'
    },
    {
      'title': 'What is the pickup process for my purchased items? ',
      'content':
          'After purchasing a rescue meal or surplus food item, you will receive a confirmation with a designated pickup time window. Simply visit the partnering establishment during this time window, show the confirmation on the app to the staff, and collect your food.'
    },
    {
      'title': 'Can I pre-order food in advance? ',
      'content':
          'Yes, Bsahtek allows users to pre-order rescue meals up to 24 hours in advance. This feature is especially useful if you want to secure your favorite meal from a particular establishment.'
    },
    {
      'title': 'Can I provide feedback on the food and service? ',
      'content':
          'Absolutely! Bsahtek values user feedback to continually improve the app and the overall experience. Users can rate and review their purchased items and the partnering establishments within the app.'
    },
    {
      'title': 'How does Bsahtek help reduce food waste? ',
      'content':
          'Bsahtek contributes to reducing food waste by enabling partnering establishments to sell their surplus food before it goes bad. By offering these items at a discounted price to users, the app encourages a more sustainable approach to food consumption.'
    },
    {
      'title': 'How can my business become a partner with Bsahtek? ',
      'content':
          'If you\'re a food establishment interested in becoming a partner with Bsahtek, you can reach out to our team through the app or our website. We\'ll be happy to discuss the partnership details and how we can work together to reduce food waste in your local community.'
    },
    {
      'title': 'Is the Bsahtek app safe and secure to use? ',
      'content':
          'Bsahtek takes the security and privacy of its users seriously. The app employs the latest security measures to protect your data and transactions. However, as with any app, it\'s essential to follow standard security practices, such as using a secure password and keeping your device updated.\n\n\n\nIf you have any other questions or concerns, feel free to contact our support team through the app or visit our website for more information. Happy rescuing with Bsahtek!'
    },
  ];

  FQAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frequently Asked Questions (FAQ)'),
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: terms.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  terms[index]['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(terms[index]['content']!),
              ],
            ),
          );
        },
      ),
    );
  }
}
