import 'package:flutter/material.dart';
import 'package:photos_server_flutter/model.dart';
import 'package:photos_server_flutter/provider/images_provider.dart';
import 'package:photos_server_flutter/provider/navigation_provider.dart';
import 'package:photos_server_flutter/widget/fullscreen.dart';
import 'package:provider/provider.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ImageView extends StatelessWidget {
  final ImageDto detail;
  final double width;
  final PicturesOfFolderView? parentFolder;
  final List<Picture> pictures;

  const ImageView(this.detail, this.width, this.pictures, this.parentFolder,
      {Key? key})
      : super(key: key);

  List<double> computeDimensions() {
    // smallest length must be set to width
    double computeWidth = 0;
    double computeHeight = 0;
    if (detail.width > detail.height) {
      computeHeight = width;
      computeWidth = (detail.width / detail.height) * computeHeight;
    } else {
      computeWidth = width;
      computeHeight = (detail.height / detail.width) * computeWidth;
    }
    return [computeWidth, computeHeight];
  }

  List<double> computeRatio(List<double> dimensions) {
    double factorWidth = 1;
    double factorHeight = 1;
    if (dimensions[0] > dimensions[1]) {
      factorWidth = dimensions[1] / dimensions[0];
    } else {
      factorHeight = dimensions[0] / dimensions[1];
    }
    return [factorWidth, factorHeight];
  }

  Widget getImageWithRatio(BuildContext context, Navigation n) {
    List<double> dimensions = computeDimensions();
    List<double> ratios = computeRatio(dimensions);
    return GestureDetector(
        onTap: () {
          n.setPrevious(parentFolder!);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullscreenImage(
                      detail.fullscreenUrl,
                      detail.hdUrl,
                      detail.height > detail.width,
                      detail.index,
                      detail.nb,
                      pictures)));
        },
        child: ClipRect(
          child: Container(
            color: Colors.blue,
            child: Align(
              widthFactor: ratios[0],
              heightFactor: ratios[1],
              alignment: Alignment.center,
              child: FolderHelper().getImageWithSize(
                  detail.littleUrl, dimensions[0], dimensions[1]),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Navigation>(
      builder: (ctx, nav, child) {
        return getImageWithRatio(context, nav);
      },
    );
    //return getImageWithRatio(context);
  }
}

class SubFolderView extends StatefulWidget {
  final Folder folder;
  final Widget parentWidget;

  const SubFolderView(this.folder, this.parentWidget, {Key? key})
      : super(key: key);

  @override
  State<SubFolderView> createState() => SubFolderViewState();
}

class SubFolderViewState extends State<SubFolderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FolderBar(widget.folder.name, widget.parentWidget),
        body: SingleChildScrollView(
          child: Container(
              color: Colors.black,
              child: FoldersView(widget.folder.children, widget)),
        ));
  }
}

class FoldersView extends StatelessWidget {
  final List<Folder> folders;
  final Widget parentWidget;

  const FoldersView(this.folders, this.parentWidget, {Key? key})
      : super(key: key);

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

  const FolderView(this.folder, this.parentWidget, {Key? key})
      : super(key: key);

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
                  builder: (context) => PicturesOfFolderView(
                      folder.name, folder.link, parentWidget,
                      key: key)));
        },
      ));
      row.children.add(const SizedBox(width: 10));
    }
    if (folder.children.isNotEmpty) {
      row.children.add(ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SubFolderView(folder, parentWidget)));
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
  final String name;
  final String searchKey;
  final Widget parentWidget;
  final bool loadByDate;

  PicturesOfFolderView(this.name, this.searchKey, this.parentWidget,
      {this.loadByDate = false, Key? key})
      : super(key: key);

  List<Widget> get(List<Picture> pictures, double width) {
    double size = width / 2;
    List<Widget> list = List.empty(growable: true);
    List<ImageView> images = List.empty(growable: true);
    pictures.asMap().forEach((index, picture) {
      images.add(ImageView(
          ImageDto(picture.low, picture.medium, picture.high, index,
              picture.width, picture.height, pictures.length),
          size,
          pictures,
          this));
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
    late Future<List<Picture>> pictures = loadByDate
        ? FolderHelper.getPhotosByDate(searchKey)
        : FolderHelper.getPhotosOfFolder(searchKey);

    Navigation n = Provider.of<Navigation>(context);

    return Scaffold(
      appBar: FolderBar(name, parentWidget),
      body: FutureBuilder(
        future: pictures,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
                controller: n.newScroller(name),
                child: Column(
                  children: get(snapshot.data as List<Picture>,
                      MediaQuery.of(context).size.width),
                ));
          } else {
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text("Impossible de charger les photos"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  )
                ],
              );
            }
            return const Text("Loading");
          }
        },
      ),
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
      leading: IconButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => parentWidget));
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
    );
  }
}
