import 'package:bandnamesapp/src/pages/home_page.dart';
import 'package:bandnamesapp/src/pages/status_page.dart';
import 'package:bandnamesapp/src/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BandNamesApp',
        initialRoute: 'home',
        routes: {
          'home': (BuildContext context) => HomePage(),
          'status': (BuildContext context) => StatusPage(),
        },
      ),
    );
  }
}
