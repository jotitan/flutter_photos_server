import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photos_server_flutter/calendar_screen.dart';
import 'package:photos_server_flutter/provider/images_provider.dart';
import 'package:photos_server_flutter/provider/navigation_provider.dart';
import 'package:photos_server_flutter/widget/folders_screen.dart';
import 'package:provider/provider.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => FilterValueStore()),
        ChangeNotifierProvider(create: (context) => Navigation()),
        ChangeNotifierProvider(create: (context) => DataSingletonProvider()),
      ], child: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photos server',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage('Photos server', key),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  HomePage(this.title, Key? key) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState(title);
}

class HomePageState extends State<HomePage> {
  final String title;

  HomePageState(this.title);

  @override
  Widget build(BuildContext context) {
    return Consumer<Navigation>(
        builder: (ctx, nav, child) => Scaffold(
              appBar: MyAppBar(title),
              body: nav.currentTab == 1 ? PhotosCalendar() : FoldersScreen(),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.folder), label: "Dossier"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month), label: "Calendrier"),
                ],
                currentIndex: nav.currentTab,
                onTap: (id) {
                  setState(() {
                    nav.currentTab = id;
                  });
                },
              ),
            )
    );
  }
}
