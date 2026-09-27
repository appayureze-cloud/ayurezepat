import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/FirebaseModels/user_chat.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/check_otp_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/network_api.dart';
import '../api/retrofit_Api.dart';
import '../const/Palette.dart';
import '../v2/ui/authentication/otp_verification.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  bool check = false;

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
        email: SharedPreferenceHelper.getString(FirestoreConstants.email)!,
        password:
            SharedPreferenceHelper.getString(FirestoreConstants.password)!,
      ))
          .user;
      if (user != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: user.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(user.uid)
              .set({
            FirestoreConstants.nickname:
                SharedPreferenceHelper.getString(FirestoreConstants.nickname)!,
            FirestoreConstants.photoUrl:
                SharedPreferenceHelper.getString(FirestoreConstants.photoUrl)!,
            FirestoreConstants.userType: "patient",
            FirestoreConstants.id: user.uid,
            FirestoreConstants.userId:
                SharedPreferenceHelper.getString(Preferences.userId),
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          User? currentUser = user;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.nickname, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.userType, userChat.userType);
        }
        _status = Status.authenticated;
        notifyListeners();
        return check = true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return check = false;
      }
    } on FirebaseAuthException catch (signUpError) {
      if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE' ||
          signUpError.code == "email-already-in-use") {
        User? user = (await _auth.signInWithEmailAndPassword(
          email: SharedPreferenceHelper.getString(FirestoreConstants.email)!,
          password:
              SharedPreferenceHelper.getString(FirestoreConstants.password)!,
        ))
            .user;
        if (user != null) {
          final QuerySnapshot result = await firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .where(FirestoreConstants.id, isEqualTo: user.uid)
              .get();
          final List<DocumentSnapshot> documents = result.docs;
          if (documents.length == 0) {
            firebaseFirestore
                .collection(FirestoreConstants.pathUserCollection)
                .doc(user.uid)
                .set({
              FirestoreConstants.nickname: SharedPreferenceHelper.getString(
                  FirestoreConstants.nickname)!,
              FirestoreConstants.photoUrl: SharedPreferenceHelper.getString(
                  FirestoreConstants.photoUrl)!,
              FirestoreConstants.userType: "patient",
              FirestoreConstants.id: user.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.chattingWith: null
            });
            // print("UserId ${user.uid} ${FirestoreConstants.id}");

            User? currentUser = user;
            await prefs.setString(FirestoreConstants.id, currentUser.uid);
            await prefs.setString(
                FirestoreConstants.nickname, currentUser.displayName ?? "");
            await prefs.setString(
                FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          } else {
            DocumentSnapshot documentSnapshot = documents[0];
            UserChat userChat = UserChat.fromDocument(documentSnapshot);

            await prefs.setString(FirestoreConstants.id, userChat.id);
            await prefs.setString(
                FirestoreConstants.nickname, userChat.nickname);
            await prefs.setString(
                FirestoreConstants.photoUrl, userChat.photoUrl);
            await prefs.setString(
                FirestoreConstants.userType, userChat.userType);
          }

          _status = Status.authenticated;
          notifyListeners();

          return check = true;
        } else {
          _status = Status.authenticateError;
          notifyListeners();
          return check = false;
        }
      } else {
        return check = false;
      }
    }
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
  }

  Future<bool> handleGoogleSignIn(BuildContext context) async {
    _status = Status.authenticating;
    notifyListeners();

    try {
      Preferences.onLoading(context);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _status = Status.authenticateCanceled;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Force-refresh so the token we hand the backend is current. From
        // here on, API calls always re-pull the token from FirebaseAuth
        // (see RetroApi._currentIdToken) rather than trusting this cached
        // copy, so no manual refresh call against Google's REST API is
        // needed.
        String? idToken = await firebaseUser.getIdToken(true);

        if (idToken != null) {
          await SharedPreferenceHelper.setString(
              Preferences.auth_token, idToken);

          CheckOtpModel response =
              await RestClient(await RetroApi().dioData(context)).googleSignIn(
                  SharedPreferenceHelper.getString(
                      Preferences.notificationRegisterKey));
          if (response.success == true) {
            _status = Status.authenticated;
            notifyListeners();

            SharedPreferenceHelper.setString(
                FirestoreConstants.email, response.data!.email!);
            SharedPreferenceHelper.setString(
                FirestoreConstants.nickname, response.data!.name!);
            SharedPreferenceHelper.setString(
                FirestoreConstants.photoUrl, response.data!.fullImage!);
            SharedPreferenceHelper.setString(
                Preferences.image, response.data!.fullImage!);
            SharedPreferenceHelper.setString(
                Preferences.image, response.data!.fullImage!);
            SharedPreferenceHelper.setString(
                Preferences.userId, response.data!.id.toString());
            SharedPreferenceHelper.setString(
                Preferences.phone, response.data!.phone?.toString() ?? '+91');
            SharedPreferenceHelper.setString(Preferences.phoneCode,
                response.data!.phoneCode?.toString() ?? '+91');
            int? verify = response.data!.verify;
            int? id = response.data!.id;
            SharedPreferenceHelper.setBoolean(Preferences.is_logged_in, true);
            Preferences.hideDialog(context);
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
            verify != 0
                ? Navigator.pushReplacementNamed(context, "Home")
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTPVerification(id: id),
                    ),
                  );
            return true;
          } else {
            _status = Status.authenticateError;
            SharedPreferenceHelper.clearPref();
            notifyListeners();
            Preferences.hideDialog(context);
            return false;
          }
        } else {
          _status = Status.authenticateError;
          SharedPreferenceHelper.clearPref();
          notifyListeners();
          Preferences.hideDialog(context);
          return false;
        }
      }
      _status = Status.authenticateError;
      SharedPreferenceHelper.clearPref();
      notifyListeners();
      Preferences.hideDialog(context);
      return false;
    } catch (e) {
      debugPrint('E:-- $e');
      _status = Status.authenticateError;
      SharedPreferenceHelper.clearPref();
      notifyListeners();
      Preferences.hideDialog(context);
      return false;
    }
  }
}
