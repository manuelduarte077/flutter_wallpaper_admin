import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/pages/home.dart';
import 'package:admin/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<AdminBloc>(create: (context) => AdminBloc()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Muli',
        appBarTheme: AppBarTheme(
          color: Colors.white,
          textTheme: TextTheme(
            headline6: TextStyle(
              fontFamily: 'Muli', 
              color: Colors.grey[900],fontWeight: FontWeight.w700, fontSize: 18),
          ),
          elevation: 0,
          actionsIconTheme: IconThemeData(
            color: Colors.grey[900],
          ),
          iconTheme: IconThemeData(
            color: Colors.grey[900]
          )
        ),
        
      ),
      home: MyApp1(),
    ),
    
    
    
    
    
    );
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ab = context.watch<AdminBloc>();
    return ab.isSignedIn == false ? SignInPage() : HomePage();
  }
}
