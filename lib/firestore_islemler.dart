import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreIslemleri extends StatelessWidget {
  FirestoreIslemleri({Key? key}) : super(key: key);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscribe;
  @override
  Widget build(BuildContext context) {
    //IDler

    debugPrint(_firestore.collection("users").id);
    debugPrint(_firestore.collection("users").doc().id);

    return Scaffold(
      appBar: AppBar(title: Text("Firestore İşlemleri")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  veriEklemeAdd();
                },
                child: Text("Veri Ekle Add")),
            ElevatedButton(
                onPressed: () {
                  veriEklemeSet();
                },
                child: Text("Veri Ekle Set")),
            ElevatedButton(
                onPressed: () {
                  veriGuncelle();
                },
                child: Text("Veri Güncelle")),
            ElevatedButton(
                onPressed: () {
                  veriSil();
                },
                child: Text("Veri Sil")),
            ElevatedButton(
                onPressed: () {
                  verileriOku();
                },
                child: Text("Verileri Oku")),
            ElevatedButton(
                onPressed: () {
                  veriOkuRealTime();
                },
                child: Text("Verileri Gerçek Zamanlı Oku")),
            ElevatedButton(
                onPressed: () {
                  streamDurdur();
                },
                child: Text("Gerçek Zamanlı Okumayı Durdur")),
            ElevatedButton(
                onPressed: () {
                  batchKavrami();
                },
                child: Text("Batch Kavrami")),
            ElevatedButton(
                onPressed: () {
                  transactionKavrami();
                },
                child: Text("Transaction Kavrami")),
            ElevatedButton(
                onPressed: () {
                  queryingData();
                },
                child: Text("querying Data")),
            ElevatedButton(
                onPressed: () {
                  kameraGaleriImageUpload();
                },
                child: Text("Kamera Galeri Image Upload")),
          ],
        ),
      ),
    );
  }

  Future<void> veriEklemeAdd() async {
    Map<String, dynamic> _eklenecekUser = <String, dynamic>{};
    _eklenecekUser["isim"] = "Ahmet";
    _eklenecekUser["yas"] = 34;
    _eklenecekUser["ogrenciMi"] = false;
    _eklenecekUser["adres"] = {"il": "Kayser", "ilce": "Melikgazi"};
    _eklenecekUser["Renkler"] = FieldValue.arrayUnion(["mavi", "siyah"]);
    //oluşturulma tarihi için yazdığımız kod
    _eklenecekUser["createdAt"] = FieldValue.serverTimestamp();

    await _firestore.collection("users").add(_eklenecekUser);
  }

  Future<void> veriEklemeSet() async {
    var yeniDocId = _firestore.collection("users").doc().id;

    await _firestore.doc("users/" + yeniDocId).set({
      "araba": "bmw",
      "userID": yeniDocId,
    });

    await _firestore.doc("users/VRlWFZVsZPJkKlTPRSMA").set({
      "okul": "Suleyman Demirel Universty",
      "yas": FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> veriGuncelle() async {
    await _firestore.doc("users/VRlWFZVsZPJkKlTPRSMA").update({
      "adres.ilce": "fatih",
      "adres.il": "Kayseri",
    });
  }

  Future<void> veriSil() async {
    //direk koleksiyon silme
    await _firestore.doc("users/tE7C9AmkRCBrLEgVWKyg").delete();

    //koleksiyon içindeki bir sütnun silme
    await _firestore.doc("users/KxcNVExo8sE8pe7c8jSE").update({
      "araba": FieldValue.delete(),
    });
  }

  Future<void> verileriOku() async {
    var _usersDocument = await _firestore.collection("users").get();
    debugPrint(_usersDocument.size.toString());
    debugPrint(_usersDocument.docs.length.toString());
    for (var eleman in _usersDocument.docs) {
      print("Döküman id ${eleman.id}");

      Map userMap = eleman.data();
      print(userMap["isim"]);
    }
    var _emreDoc = await _firestore.doc("users/VRlWFZVsZPJkKlTPRSMA").get();
    print(_emreDoc.data().toString());
    print(_emreDoc.data()!["adres"]["ilce"]);
  }

  Future<void> veriOkuRealTime() async {
    //user içersiindeki tek bir elemanı dinleme.
    var _userDocStream =
        await _firestore.doc("users/VRlWFZVsZPJkKlTPRSMA").snapshots();
    _userSubscribe = _userDocStream.listen((event) {
      print(event.data().toString());
    });
    //bütün useeri dinleme

    //docChanges methodu ile stream dinleme
    /* var userStream = await _firestore.collection("users").snapshots();
    _userSubscribe = userStream.listen((event) {
    /*  event.docChanges.forEach((element) {
        print(element.doc.data().toString());
      });*/*/
    //doc methoduyla stream okuma
    /*
      event.docs.forEach((element) {
        print(element.data().toString());
      });
    });
    */
  }

  Future<void> streamDurdur() async {
    await _userSubscribe?.cancel();
  }

  Future<void> batchKavrami() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterColRef = _firestore.collection("counter");
    /*Batch ile eleman ekleme.
    for(int i = 0 ; i<100;i++)
    {
      var yeniDoc = _counterColRef.doc();
      _batch.set(yeniDoc, {"sayac":++i , "id":yeniDoc.id});
    }
    */
    //Batch ile toplu güncelleme yapma
    /*
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(element.reference,{"createdAt":FieldValue.serverTimestamp()});
    });
    */
    //BATCH VERİ SİLME
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });

    await _batch.commit();
  }

  void transactionKavrami() {
    _firestore.runTransaction((transaction) async {
      //Emrenin bakiyesini öğren
      //emreden 100 lira düş
      //hasana 100 lira ekle

      DocumentReference<Map<String, dynamic>> emreRef =
          _firestore.doc("users/6QCpuQ7VxShvAiMz2AU3");
      DocumentReference<Map<String, dynamic>> ahmetRef =
          _firestore.doc("users/VRlWFZVsZPJkKlTPRSMA");

      var emreSnapshot = await transaction.get(emreRef);
      var _emreBakiye = emreSnapshot.data()!['para'];
      if (_emreBakiye > 100) {
        var _yeniBakiye = emreSnapshot.data()!["para"] - 100;
        transaction.update(emreRef, {"para": _yeniBakiye});
        transaction.update(ahmetRef, {"para": FieldValue.increment(100)});
      }
    });
  }

  Future<void> queryingData() async {
    //istediği kadar değer gelsin sen bana ilkini ver dediğimizde limit operatörünü kullanırız.
    //var _userRef =_firestore.collection("users").limit(1);
    var _userRef = _firestore.collection("users");
    //var _sonuc = await _userRef.where("yas",whereIn: [30,40]).get();
    var _sonuc = await _userRef.where("Renkler", arrayContains: "mavi").get();
    /* for(var user in _sonuc.docs)
    {
      print(user.data().toString());
    }*/
    //sıralama olayı bu şekilde yapılmaktadır descending özelliği true olursa sıralamanın büyükten küçüğe  şekilde yapılacağını gösterir.
    /*var _sirala = await _userRef.orderBy("yas",descending: false).get();
     for(var user in _sirala.docs)
    {
      print(user.data().toString());
    }*/

    var _stringSearch = await _userRef
        .orderBy("email")
        .startAt(["ahmet"]).endAt(["ahmet" + "\uf8ff"]).get();
    for (var user in _stringSearch.docs) {
      print(user.data().toString());
    }
  }

  Future<void> kameraGaleriImageUpload() async {
    final ImagePicker _picker = ImagePicker();

    XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    var _profileRef = FirebaseStorage.instance.ref("users/profil_resimleri");
    var _task =_profileRef.putFile(File(_file!.path));
    _task.whenComplete(() async {
      var _url = await _profileRef.getDownloadURL();
      _firestore.doc("users/KxcNVExo8sE8pe7c8jSE").set({
        "profile_pic":_url.toString()
      },SetOptions(merge:true));
      print(_url);
    });
  }
}
