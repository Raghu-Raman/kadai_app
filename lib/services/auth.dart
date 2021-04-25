//import 'package:brew_crew/services/user_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kadai_app/models/user.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create FUser obj based on User
  FUser _userFromUser(User user) {
    return user != null ? FUser(uid: user.uid, email: user.email, isVerified: user.emailVerified) : null;
  }

  // auth change user stream
  Stream<FUser> get user {
    //return _auth.authStateChanges().map(_userFromUser);
    return _auth.authStateChanges().map((User user) => _userFromUser(user));
  }


  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      print(user);
      return _userFromUser(user);

    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password).whenComplete(() => _auth.currentUser.sendEmailVerification()).whenComplete(signOut);
      User user = userCredential.user;

      // create a new document for the user with the uid
      //await DatabaseService(uid: user.uid).updateUserData('0', 'new crew member', 100);
      return _userFromUser(user);

    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

}