import 'package:admin/utils/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ScrollController controller;
  DocumentSnapshot _lastVisible;
  bool _isLoading;
  List<DocumentSnapshot> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection('users')
          .orderBy('timestamp', descending: true)
          .limit(15)
          .get();
    else
      data = await firestore
          .collection('users')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible['timestamp']])
          .limit(15)
          .get();

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading = false);
      openToast(context, 'No more contents available');
    }
    return null;
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 30),
        padding: EdgeInsets.only(
          left: w * 0.05,
          right: w * 0.20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey[300],
              blurRadius: 10,
              offset: Offset(3, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              'Users',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 10),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 20, bottom: 30),
                  controller: controller,
                  itemCount: _data.length + 1,
                  itemBuilder: (_, int index) {
                    if (index < _data.length) {
                      final DocumentSnapshot d = _data[index];
                      return _buildUserList(d);
                    }
                    return Center(
                      child: new Opacity(
                        opacity: _isLoading ? 1.0 : 0.0,
                        child: new SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: new CircularProgressIndicator(),
                        ),
                      ),
                    );
                  },
                ),
                onRefresh: () async {
                  _data.clear();
                  _lastVisible = null;
                  await _getData();
                },
              ),
            ),
          ],
        ));
  }

  Widget _buildUserList(d) {
    String imageUrl = d['image url'];
    String email = d['email'];
    String uid = d['uid'];
    String name = d['name'];
    return ListTile(
      leading: imageUrl == null || imageUrl.isEmpty
          ? CircleAvatar()
          : CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('$email \nUID: $uid'),
      isThreeLine: true,
    );
  }
}
