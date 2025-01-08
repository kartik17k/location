import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> sendNotification(String name, String address) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'title': "Hello $name!",
    'body': "How was the $address?",
  });
}
