import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/utils/content_preview.dart';
import 'package:admin/utils/dialog.dart';
import 'package:admin/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UploadItem extends StatefulWidget {
  UploadItem({Key key}) : super(key: key);

  @override
  _UploadItemState createState() => _UploadItemState();
}

class _UploadItemState extends State<UploadItem> {

  var formKey = GlobalKey<FormState>();
  var imageUrlCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  
  String date;
  String timestamp;
  int loves;
  var categorySelection;
  bool uploadStarted = false;





  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if(categorySelection == null){
      openDialog(context, 'Select Category First', '');
    }else{
      if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (ab.userType == 'tester') {
        openDialog(context, 'You are a Tester', 'Only Admin can upload, delete & modify contents');
      } else {
        setState(()=> uploadStarted = true);
        getDate().then((_) async{
          await saveToDatabase()
          .then((value) => ab.increaseCount('contents_count'));
          setState(()=> uploadStarted = false);
          openDialog(context, 'Uploaded Successfully', '');
          clearTextFeilds();
          
          
        });
      }
    }
    }
  }







  Future getDate() async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd MMMM yy').format(now);
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      date = _date;
      timestamp = _timestamp;
    });
    
  }



  Future saveToDatabase() async {
    final DocumentReference ref = firestore.collection('contents').doc(timestamp);
    await ref.set({
      'image url': imageUrlCtrl.text,
      'loves': 0,
      'category': categorySelection,
      'timestamp': timestamp,
      
    });
  }

  


  clearTextFeilds() {
    
    imageUrlCtrl.clear();
    FocusScope.of(context).unfocus();
  }




  handlePreview() async{
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      await showContentPreview(context, imageUrlCtrl.text);
    }
  }




  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                  'Content Details',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 40,),

                categoryDropdown(),

                
                SizedBox(height: 20,),


                TextFormField(
                  decoration: inputDecoration('Enter Image Url', 'Image', imageUrlCtrl),
                  controller: imageUrlCtrl,
                  validator: (value) {
                    if (value.isEmpty) return 'Value is empty';
                    return null;
                  },
                  
                ),
                
                
               

                SizedBox(height: 100,),


                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        
                       
                        TextButton.icon(
                          
                          icon: Icon(Icons.remove_red_eye, size: 25, color: Colors.blueAccent,),
                          label: Text('Preview', style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black
                          ),),
                          onPressed: (){
                            handlePreview();
                          }
                        )
                      ],
                    ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    color: Colors.deepPurpleAccent,
                    height: 45,
                    child: uploadStarted == true
                      ? Center(child: Container(height: 30, width: 30,child: CircularProgressIndicator()),)
                      : TextButton(
                        child: Text(
                          'Upload Content',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async{
                          handleSubmit();
                          
                        })
                      
                      ),
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
                categorySelection = value;
              });
            },
            onSaved: (value) {
              setState(() {
                categorySelection = value;
              });
            },
            value: categorySelection,
            hint: Text('Select Category'),
            items: ab.categoryNames.map((f) {
              return DropdownMenuItem(
                child: Text(f),
                value: f,
              );
            }).toList()));
  }



}
