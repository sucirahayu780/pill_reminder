import 'package:flutter/material.dart';
import 'package:pill_reminder/database/db_helper.dart';
import 'package:pill_reminder/screens/home_screen.dart';
import 'package:pill_reminder/services/notifications_helper.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await DbHelper.initDb();
  // await NotificationsHelper.InitializeNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
          title: "Reminder App",
          debugShowCheckedModeBanner: false, 
          theme: ThemeData(
            primarySwatch: Colors.teal,
            fontFamily: 'montserrat',
            textTheme : TextTheme(
              bodyLarge: TextStyle( 
                fontSize: 16,
                color: Colors.black87,
              ),
              bodyMedium: TextStyle( 
                fontSize: 14,
                color: Colors.black54,
              ),
              titleLarge: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
          ),
          ),
          home: HomeScreen(),
        ); 
    }
}
            