import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_dersleri/firebase_options.dart';

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
      home: MyHomePage(),
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
  final String _email = "ahmet.karabudakk.9122@gmail.com";
  final String _password = "password12345";
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
    await auth.signOut();
  }

  Future<void> deleteUSer() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    }
    else
    {
      print("Kullamıcı oturum açmadığı için silinemez");
    }
  }
}
