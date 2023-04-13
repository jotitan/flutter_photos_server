import 'package:flutter/material.dart';
import 'package:photos_server_flutter/list_photos.dart';
import 'package:photos_server_flutter/model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) {
        return FilterValueStore();
      },
      child: const MyApp()));
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
      //home: CropTest(key),
    );
  }
}

class CropTest extends StatelessWidget {
  const CropTest(Key? key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar('Test'),
        body: Row(
          children:[
            ImageView(
                ImageDto("/image/PHOTOS/2016/2016_05_SAINT_MALO/IMG_1256_Dxo-250.jpg", "", 1, 375, 250, 1), 180, List.empty(), null),
            ImageView(
                ImageDto("/image/PHOTOS/2016/2016_05_SAINT_MALO/IMG_1174_Dxo-250.jpg", "", 2, 250, 375, 1), 180, List.empty(), null),
            ]
            /*ClipRect(
              child:
              Container(
                color: Colors.blue,
                child:Align(
                  child: FolderHelper().getImage(
                      "/image/PHOTOS/2016/2016_05_SAINT_MALO/IMG_1256_Dxo-250.jpg"),
                  heightFactor: 1.1,
                  widthFactor: 0.45,
                  alignment: Alignment.center,
                ),
              ),
            ),
            ClipRect(
              child:
              Container(
                color: Colors.red,
                child:Align(
                  child: FolderHelper().getImage(
                      "/image/PHOTOS/2016/2016_05_SAINT_MALO/IMG_1259_Dxo-250.jpg"),
                  heightFactor: 1.1,
                  widthFactor: 0.45,
                  alignment: Alignment.center,
                ),
              ),
            )
          ]*/
        )
    );
  }
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

class FilterValueStore extends ChangeNotifier {
  String value = "";

  void update(String v) {
    value = v;
    notifyListeners();
  }
}

class FilterFolders extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  FilterFolders(Key? key) {}

  void runSearch(FilterValueStore store) {
    store.update(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    var store = context.watch<FilterValueStore>();
    controller.text = store.value;
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
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                    hintText: "Répertoire",
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none),
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
                child: IconButton(
                    onPressed: () => runSearch(store),
                    icon: Icon(Icons.loupe_rounded))),
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

  Future<Folder> getFolders(String filter) {
    print("GET FOLERS $filter");
    if (filter.isEmpty) {
      return folders;
    } else {
      return filterFolders(filter);
    }
  }

  Future<Folder> filterFolders(String filter) async {
    Folder f = await folders;
    return Folder(
        f.name, f.link, f.hasImages, filterChildren(f.children, filter));
  }

  List<Folder> filterChildren(List<Folder> folders, String filter) {
    List<Folder> filtered = List.empty(growable: true);
    for (var folder in folders) {
      if (folder.name.contains(filter)) {
        filtered.add(folder);
      } else {
        if (folder.children.isNotEmpty) {
          List<Folder> filteredChildren =
              filterChildren(folder.children, filter);
          if (filteredChildren.isNotEmpty) {
            filtered.add(Folder(
                folder.name, folder.link, folder.hasImages, filteredChildren));
          }
        }
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(0, 21, 34, 1),
        child: Consumer<FilterValueStore>(builder: (context2, store, child) {
          return FutureBuilder<Folder>(
              future: getFolders(store.value),
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
              });
        }));
  }
}
