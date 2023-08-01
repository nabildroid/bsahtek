import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final List<Map<String, String>> terms = [
    {
      'title': 'Privacy Policy for Bsahtek',
      'content':
          'This Privacy Policy explains how Samok Co collects, uses, shares, and protects your personal information when you use the Bsahtek mobile application. By accessing or using the App, you consent to the collection and use of your personal information as described in this Policy. If you do not agree with this Policy, you must not use the App.  \n\n Information We Collect \n\n 1.1. Personal Information: We may collect personal information that you provide to us when you create an account, such as your name, email address, phone number, and payment information. \n\n 1.2. Usage Information: We may collect information about your interactions with the App, including the features you use, the content you view, and your preferences. \n\n 1.3. Location Information: With your consent, we may collect your precise location information through the App to provide location-based services and connect you with nearby Merchants.'
    },
    {
      'title': 'Use of Information',
      'content':
          '2.1. We use the collected information to:  \n\nProvide and improve the App\'s functionality, features, and services.  \n\nProcess and fulfill your orders and transactions with the merchants.  \n\nCommunicate with you regarding your account, orders, and App updates. \n\nPersonalize your experience with the App and provide relevant recommendations.  \n\nAnalyze and monitor usage patterns and trends to enhance the App\'s performance.  \n\nDetect, prevent, and address technical issues, fraud, or other unauthorized activities.'
    },
    {
      'title': 'Sharing of Information',
      'content':
          '3.1. We may share your personal information with third parties in the following circumstances:  \n\nWith Merchants to facilitate the purchase and delivery of surplus food. \n\nWith service providers who assist us in operating the App and providing related services. \n\nWith business partners and affiliates for marketing and promotional purposes, with your consent.  \n\nIn response to a valid legal request or to comply with applicable laws, regulations, or legal processes.  \n\nTo protect our rights, property, or safety, and that of our users or others.'
    },
    {
      'title': 'Data Security',
      'content':
          '4.1. We implement reasonable security measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is completely secure, and we cannot guarantee absolute security.'
    },
    {
      'title': 'Third-Party Links and Services',
      'content':
          '5.1. The App may contain links to third-party websites or services that are not owned or controlled by us. This Policy does not apply to those third-party websites or services. We recommend reviewing the privacy policies of those third parties before providing any personal information.'
    },
    {
      'title': 'Children\'s Privacy',
      'content':
          '6.1. The App is not intended for use by individuals under the age of 18. We do not knowingly collect personal information from children under 18. If we become aware that we have inadvertently collected personal information from a child under 18, we will take steps to delete such information as soon as possible.'
    },
    {
      'title': 'Changes to this Policy',
      'content':
          '7.1. We may update this Policy from time to time. The updated Policy will be effective upon posting the revised version on the App. We encourage you to review this Policy periodically to stay informed about how we collect, use, and protect your information.'
    },
    {
      'title': 'Contact Us',
      'content':
          '8.1. If you have any questions, concerns, or requests regarding this Policy or our privacy practices, please contact us at contact information. \n\nBy using the App, you acknowledge that you have read and understood this Privacy Policy and consent to the collection, use, and sharing of your personal information as described herein.'
    },
  ];

  TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
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
