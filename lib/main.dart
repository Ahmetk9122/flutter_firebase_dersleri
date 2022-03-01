import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_dersleri/firebase_options.dart';
import 'package:flutter_firebase_dersleri/firestore_islemler.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: FirestoreIslemleri(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  final String _email = "ahmet.karabudakk@gmail.com";
  final String _password = "yenisifre";
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User oturumu kapalı!');
      } else {
        print('User oturumu açtı! ve email durumu ${user.emailVerified}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material App Bar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  createUserEmailAndPassword();
                },
                child: Text("Email/Şifre Kayıt")),
            ElevatedButton(
                onPressed: () {
                  loginUserEmailAndPassword();
                },
                child: Text("Email/Şifre Girişi")),
            ElevatedButton(
                onPressed: () {
                  signOutUser();
                },
                child: Text("Oturumu Kapat")),
            ElevatedButton(
                onPressed: () {
                  deleteUSer();
                },
                child: Text("Kullanıcıyı Sil!")),
            ElevatedButton(
                onPressed: () {
                  changePassword();
                },
                child: Text("Parola Değiştir")),
            ElevatedButton(
                onPressed: () {
                  changeEmail();
                },
                child: Text("Email Değiştir")),
            ElevatedButton(
                onPressed: () {
                  googleIleGiris();
                },
                child: Text("Google ile Giriş")),
            ElevatedButton(
                onPressed: () {
                  loginWithPhoneNumber();
                },
                child: Text("Tel No Giriş")),
          ],
        ),
      ),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint("Kullanıcı maili onaylanmış ilgili sayfaya gidebilir");
      }
      print(_userCredential.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      print(_userCredential.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  void signOutUser() async {
    var _user = await GoogleSignIn().currentUser;
    //Google(gmail) ile çıkış yaperken.
    if (_user != null) {
      await GoogleSignIn().signOut();
    }
    //Firebase kısmından çıkış yaparken.
    await auth.signOut();
  }

  Future<void> deleteUSer() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      print("Kullamıcı oturum açmadığı için silinemez");
    }
  }

  Future<void> changePassword() async {
    try {
      await auth.currentUser!.updatePassword("yenisifre");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        print("reauthenticate olacak");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword("yenisifre");
        await auth.signOut();
        debugPrint("şifre güncellendi");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> changeEmail() async {
    try {
      await auth.currentUser!.updateEmail("ahmet.karabudak@gmail.com");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        print("reauthenticate olacak");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updateEmail("ahmet.karabudak@gmail.com");
        await auth.signOut();
        debugPrint("email güncellendi");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void googleIleGiris() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> loginWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+905385555555',
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("verification complated tetiklendi Telefonla girildi");
        print(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        String _smsCode = "912238";
        print("Code sent tetiklendi");
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);

        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Code auto retrival tetiklendi");
      },
    );
  }
}
