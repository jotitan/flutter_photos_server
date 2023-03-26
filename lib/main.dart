import 'package:flutter/material.dart';
import 'package:photos_server_flutter/list_photos.dart';
import 'package:photos_server_flutter/model.dart';

void main() {
  runApp(const MyApp());
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
      home: MyRealHomePage('Photos server', key),
    );
  }
}

class Counter extends StatefulWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class MyRealHomePage extends StatelessWidget {
  final String title;

  const MyRealHomePage(this.title, Key? key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title),
      body: SingleChildScrollView(
        child: Column(
          children: [FilterFolders(key), Folders(this)],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class FilterFolders extends StatelessWidget {
  const FilterFolders(Key? key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(0, 21, 34, 1),
        child: Row(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: const TextField(
                decoration: InputDecoration(
                    hintText: "Répertoire",
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none),
                onChanged: null,
              ),
            )),
            const SizedBox(width: 10),
            Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 40,
                height: 40,
                child: Icon(Icons.loupe_rounded)),
            const SizedBox(width: 10),
          ],
        ));
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => const Size.fromHeight(50);
  final String title;

  const MyAppBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color.fromRGBO(0, 21, 34, 1),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }
}

class Folders extends StatefulWidget {
  final Widget parentWidget;
  const Folders(this.parentWidget, {Key? key}) : super(key: key);

  @override
  State<Folders> createState() => _FoldersState(parentWidget);
}

class _FoldersState extends State<Folders> {
  late final Future<Folder> folders;
  final Widget parentWidget;
  _FoldersState(this.parentWidget);

  @override
  void initState() {
    super.initState();
    folders = FolderHelper().getFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(0, 21, 34, 1),
        //height: 2000,
        child: FutureBuilder<Folder>(
            future: folders,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("Loading");
              } else {
                if (snapshot.hasError) {
                  return AlertDialog(
                    title: const Text("Impossible de charger les données"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      )
                    ],
                  );
                }
                return FoldersView(snapshot.data!.children, parentWidget);
              }
            }));
  }
}

class _CounterState extends State<Counter> {
  int _counter = 0;

  _CounterState() {}

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headline4,
          ),
          const Text('Super resultats'),
          FloatingActionButton(
              onPressed: _incrementCounter, child: const Icon(Icons.add)),
          FloatingActionButton(
              onPressed: _decrementCounter, child: const Icon(Icons.remove))
        ],
      ),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
