import 'package:flutter/material.dart';




showContentPreview(context,imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context){
      return Dialog(
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.40,
          // height: MediaQuery.of(context).size.height * 0.80,
          child: Stack(
            children: <Widget>[
              Image(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),

              Positioned(
                top: 20,
                right: 20,
                child: InkWell(
                    child: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(Icons.close, color: Colors.white,),
                  ),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      );
    }
  );
}