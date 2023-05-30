import 'package:flutter/material.dart';
import 'package:photos_server_flutter/list_photos.dart';
import 'package:photos_server_flutter/main.dart';
import 'package:photos_server_flutter/model.dart';
import 'package:photos_server_flutter/provider/images_provider.dart';
import 'package:provider/provider.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [FilterFolders(key), Folders(HomePage("Photos server", null))],
      ),
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
  final Widget parentWidget;

  _FoldersState(this.parentWidget);

  Future<Folder> getFolders(Future<Folder> folders, String filter) {
    if (filter.isEmpty) {
      return folders;
    } else {
      return filterFolders(folders, filter);
    }
  }

  Future<Folder> filterFolders(Future<Folder> folders,String filter) async {
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
        child:Consumer<DataSingletonProvider>(builder:(ctx2, singleton, child2)=>
        Consumer<FilterValueStore>(builder: (context2, store, child) {
          return FutureBuilder<Folder>(
              future: getFolders(singleton.folders,store.value),
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
        })));
  }
}
