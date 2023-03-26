import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photos_server_flutter/model.dart';
import 'package:photos_server_flutter/api_key.dart';



class GalleryView extends StatelessWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FullscreenImage extends StatefulWidget {
  final String url;
  final int index;
  final int nb;
  final List<Picture> pictures;
  final PicturesOfFolderView parentFolder;

  const FullscreenImage(this.url, this.index, this.nb, this.pictures, this.parentFolder,{Key? key})
      : super(key: key);

  @override
  State<FullscreenImage> createState() => _FullscreenImageSate(url, index, nb, pictures, parentFolder);
}

class _FullscreenImageSate extends State<FullscreenImage> {
  String url;
  int index;
  final int nb;
  final List<Picture> pictures;
  final PicturesOfFolderView parentFolder;
  bool left = false;

  _FullscreenImageSate(this.url, this.index, this.nb, this.pictures, this.parentFolder);

  void updateUrl(int idx){
    setState((){
      url = pictures[idx].medium;
      index = idx;
    });
  }

  void update(double delta) {
    left = delta != 0;
  }

  void goto(Picture picture, int index){
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        FullscreenImage(picture.medium, index, nb, pictures, parentFolder)));
  }

  void goBack(){
    Navigator.push(context,MaterialPageRoute(builder: (context)=>parentFolder));
  }

  Widget getImage() {
    return GestureDetector(
        onHorizontalDragUpdate: (e) {
          update(e.delta.direction);
        },
        onHorizontalDragEnd: (e) {
          if(left && index < nb){
            updateUrl(index+1);
            //goto(pictures[index+1], index+1);
          }
          if(!left && index > 0){
            updateUrl(index-1);
            //goto(pictures[index-1], index-1);
          }
        },
        onDoubleTap: () {
          goBack();
        },
        child: FolderHelper().getImage(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("${index+1} / $nb"), centerTitle: true,
        leading: IconButton(
            onPressed: ()=>goBack(),
            icon:const Icon(Icons.close_fullscreen)),
        ),
        body: Container(color: Colors.black, child: Center(child: getImage())));
  }
}

class ImageView extends StatelessWidget {
  final ImageDto detail;
  final double width;
  final PicturesOfFolderView parentFolder;
  final List<Picture> pictures;

  const ImageView(this.detail, this.width, this.pictures, this.parentFolder,{Key? key}) : super(key: key);

  Widget getImage(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullscreenImage(
                      detail.fullscreenUrl, detail.index, detail.nb, pictures, parentFolder)));
        },
        child: FolderHelper().getImage(detail.littleUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: width,
        child: AspectRatio(aspectRatio: 1, child: getImage(context)));
  }
}

class SubFolderView extends StatelessWidget {
  final Folder folder;
  final Widget parentWidget;

  const SubFolderView(this.folder, this.parentWidget,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FolderBar(folder.name, parentWidget),
        body: SingleChildScrollView(
          child: Container(color:Colors.black,child:FoldersView(folder.children, this)),
        ));
  }
}

class FoldersView extends StatelessWidget {
  final List<Folder> folders;
  final Widget parentWidget;

  const FoldersView(this.folders, this.parentWidget, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: folders.map((f) {
        return FolderView(f, parentWidget);
      }).toList(),
    );
  }
}

class FolderView extends StatelessWidget {
  final Folder folder;
  final Widget parentWidget;

  const FolderView(this.folder, this.parentWidget, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var row = Row(children: [
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(10),
        child: Text(folder.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      )),
    ]);
    if (folder.hasImages) {
      row.children.add(ElevatedButton(
        child: const Icon(Icons.photo),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PicturesOfFolderView(folder, parentWidget, key)));
        },
      ));
      row.children.add(const SizedBox(width: 10));
    }
    if (folder.children.isNotEmpty) {
      row.children.add(ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SubFolderView(folder, parentWidget)));
          },
          child: const Icon(Icons.folder)));
      row.children.add(const SizedBox(width: 10));
    }

    return Container(
      color: Colors.blue,
      margin: const EdgeInsets.only(bottom: 10),
      child: row,
    );
  }
}

class PicturesOfFolderView extends StatelessWidget {
  final Folder folder;
  final Widget parentWidget;

  const PicturesOfFolderView(this.folder, this.parentWidget, Key? key) : super(key: key);

  List<Widget> get(List<Picture> pictures, double width) {
    double size = width / 2;
    List<Widget> list = List.empty(growable: true);
    List<ImageView> images = List.empty(growable: true);
    pictures.asMap().forEach((index, picture) {
      images.add(ImageView(
          ImageDto(picture.low, picture.medium, index, pictures.length), size, pictures, this));
      if (images.length == 2) {
        list.add(Row(children: images));
        images = List.empty(growable: true);
      }
    });

    if (images.isNotEmpty) {
      list.add(Row(children: images));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    late Future<List<Picture>> pictures =
        FolderHelper().getPhotosOfFolder(folder);

    return Scaffold(
      appBar: FolderBar(folder.name, parentWidget),
      body: SingleChildScrollView(
          child: FutureBuilder(
        future: pictures,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: get(snapshot.data as List<Picture>, MediaQuery.of(context).size.width),
            );
          } else {
            if(snapshot.hasError){
              print( snapshot.error);
            }
            return const Text("Loading");
          }
        },
      )),
    );
  }
}

class FolderBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => const Size.fromHeight(50);
  final String title;
  final Widget parentWidget;

  const FolderBar(this.title, this.parentWidget, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      //centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>parentWidget));
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FolderHelper {
  Future<Folder> getFolders() async {

    var resp = await http.get(
        Uri.parse(
            "$endpoint/rootFolders"),
        headers: {
          HttpHeaders.cookieHeader:
              "token=$apiKey"
        });
    var content = jsonDecode(resp.body);
    var folder = Folder.fromJSON(content);
    return folder.children[0];
  }

  Future<List<Picture>> getPhotosOfFolder(Folder folder) async {
    var resp = await http.get(
        Uri.parse(
            "$endpoint${folder.link}"),
        headers: {
          HttpHeaders.cookieHeader:
              "token=$apiKey"
        });
    var content = jsonDecode(resp.body);
    var files = content["Files"] as List;
    var data = files
        .where((d) => (d as Map<String,dynamic>).containsKey("ThumbnailLink"))
        .map((f) => Picture.fromJSON(f)).toList();
    data.sort((a,b)=>a.date.compareTo(b.date));
    return data;
  }

  Image getImage(String url){
    return Image.network(
        "$endpoint$url",
        fit: BoxFit.fill,
        headers: const {
          HttpHeaders.cookieHeader:
          "token=$apiKey"
        });
  }
}
