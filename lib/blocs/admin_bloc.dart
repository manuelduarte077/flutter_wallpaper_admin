import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _adminPass;
  String _userType = 'Admin';
  bool _isSignedIn = false;
  bool _testing = false;
  List _categories = [];
  List _categoryNames = [];

  AdminBloc() {
    checkSignIn();
    getAdminPass();
    getCategories();
  }

  String get adminPass => _adminPass;
  String get userType => _userType;
  bool get isSignedIn => _isSignedIn;
  bool get testing => _testing;
  List get categories => _categories;
  List get categoryNames => _categoryNames;

  void getAdminPass() {
    FirebaseFirestore.instance
        .collection('admin')
        .doc('user type')
        .get()
        .then((DocumentSnapshot snap) {
      String _aPass = snap['admin password'];
      _adminPass = _aPass;
      notifyListeners();
    });
  }

  Future<int> getTotalDocuments(String documentName) async {
    final String fieldName = 'count';
    final DocumentReference ref =
        firestore.collection('item_count').doc(documentName);
    DocumentSnapshot snap = await ref.get();
    if (snap.exists == true) {
      int itemCount = snap[fieldName] ?? 0;
      return itemCount;
    } else {
      await ref.set({fieldName: 0});
      return 0;
    }
  }

  Future increaseCount(String documentName) async {
    await getTotalDocuments(documentName).then((int documentCount) async {
      await firestore
          .collection('item_count')
          .doc(documentName)
          .update({'count': documentCount + 1});
    });
  }

  Future decreaseCount(String documentName) async {
    await getTotalDocuments(documentName).then((int documentCount) async {
      await firestore
          .collection('item_count')
          .doc(documentName)
          .update({'count': documentCount - 1});
    });
  }

  Future deleteContent(timestamp) async {
    await firestore.collection('contents').doc(timestamp).delete();
  }

  Future getCategories() async {
    QuerySnapshot snap = await firestore.collection('categories').get();
    var x = snap.docs;

    _categories.clear();
    _categoryNames.clear();

    x.forEach((element) => _categoryNames.add(element['name']));

    x.forEach((f) => _categories.add(f));
    _categories.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    notifyListeners();
  }

  Future deleteCategory(timestamp) async {
    await firestore.collection('categories').doc(timestamp).delete();
    getCategories();
  }

  Future saveNewAdminPassword(String newPassword) async {
    await firestore.collection('admin').doc('user type').update(
        {'admin password': newPassword}).then((value) => getAdminPass());
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed in', true);
    _isSignedIn = true;
    _userType = 'admin';
    notifyListeners();
  }

  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed in') ?? false;
    notifyListeners();
  }

  Future setSignInForTesting() async {
    _testing = true;
    _userType = '123456';
    notifyListeners();
  }
}
