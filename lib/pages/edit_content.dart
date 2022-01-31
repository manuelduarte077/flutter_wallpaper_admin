import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/utils/content_preview.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class EditContent extends StatefulWidget {
  final String imageUrl, timestamp, category;
  final int loves;

  EditContent(
      {Key key,
      @required this.imageUrl,
      this.timestamp,
      this.loves,
      this.category})
      : super(key: key);

  @override
  _EditContentState createState() => _EditContentState(
      this.imageUrl, this.timestamp, this.loves, this.category);
}

class _EditContentState extends State<EditContent> {
  _EditContentState(this.imageUrl, this.timestamp, this.loves, this.category);

  String imageUrl;
  String timestamp;
  int loves;
  String category;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var formKey = GlobalKey<FormState>();
  var imageUrlCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool updateStarted = false;

  void handleUpdate() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (ab.userType == 'tester') {
        openDialog(
            context, 'You are a Tester', 'Only admin can edit/update items');
      } else {
        setState(() => updateStarted = true);
        await updateDatabase();
        setState(() => updateStarted = false);
        openDialog(context, 'Updated Successfully', '');
      }
    }
  }

  void handlePreview() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      await showContentPreview(context, imageUrl);
    }
  }

  Future updateDatabase() async {
    final DocumentReference ref =
        firestore.collection('contents').doc(timestamp);
    await ref.update({'image url': imageUrl, 'category': category});
  }

  @override
  void initState() {
    super.initState();
    imageUrlCtrl.text = imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Center(
          child: AppBar(
            elevation: 1,
            title: Text('Edit Content Data'),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton.icon(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.resolveWith((states) =>
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)))),
                  icon: Icon(
                    LineIcons.eye,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Preview',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                  onPressed: () {
                    handlePreview();
                  },
                ),
              ),
              SizedBox(
                width: 20,
              )
            ],
          ),
        ),
      ),
      key: scaffoldKey,
      body: Container(
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
                color: Colors.grey[300], blurRadius: 10, offset: Offset(3, 3))
          ],
        ),
        child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: h * 0.10,
                ),
                Text(
                  'Edit Content',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 40,
                ),
                categoryDropdown(),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration:
                      inputDecoration('Enter Image Url', 'Image', imageUrlCtrl),
                  controller: imageUrlCtrl,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty';
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      imageUrl = value;
                    });
                  },
                ),
                SizedBox(
                  height: 100,
                ),
                Container(
                    color: Colors.deepPurpleAccent,
                    height: 45,
                    child: updateStarted == true
                        ? Center(
                            child: Container(
                                height: 35,
                                width: 35,
                                child: CircularProgressIndicator()),
                          )
                        : TextButton(
                            child: Text(
                              'Update Data',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              handleUpdate();
                            })),
                SizedBox(
                  height: 200,
                ),
              ],
            )),
      ),
    );
  }

  Widget categoryDropdown() {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);

    return Container(
        height: 50,
        padding: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                category = value;
              });
            },
            onSaved: (value) {
              setState(() {
                category = value;
              });
            },
            value: category,
            hint: Text('Select Category'),
            items: ab.categoryNames.map((f) {
              return DropdownMenuItem(
                child: Text(f),
                value: f,
              );
            }).toList()));
  }
}
