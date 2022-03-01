import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreIslemleri extends StatelessWidget {
  FirestoreIslemleri({Key? key}) : super(key: key);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
     await _firestore.doc("users/VRlWFZVsZPJkKlTPRSMA").update(
       {
         "adres.ilce":"fatih", 
         "adres.il":"Kayseri", 
       }
     );
  }

  Future<void> veriSil() async {
    //direk koleksiyon silme
    await _firestore.doc("users/tE7C9AmkRCBrLEgVWKyg").delete();

    //koleksiyon içindeki bir sütnun silme
    await _firestore.doc("users/KxcNVExo8sE8pe7c8jSE").update(
      {
        "araba":FieldValue.delete(),
      }
    );
  }
}
