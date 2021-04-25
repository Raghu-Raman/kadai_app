import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FireStorageService extends ChangeNotifier {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<dynamic> loadImage({image}) async {
    return image != '' ? _firebaseStorage.ref().child(image).getDownloadURL() : '';
  }
}