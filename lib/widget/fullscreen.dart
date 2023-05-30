import 'package:flutter/material.dart';
import 'package:photos_server_flutter/model.dart';
import 'package:photos_server_flutter/provider/images_provider.dart';
import 'package:photos_server_flutter/provider/navigation_provider.dart';
import 'package:provider/provider.dart';

const minScale = 1.0;
const maxScale = 2.5;

class FullscreenImage extends StatefulWidget {
  final String url;
  final int index;
  final int nb;
  final List<Picture> pictures;

  const FullscreenImage(this.url, this.index, this.nb, this.pictures,
      {Key? key})
      : super(key: key);

  @override
  State<FullscreenImage> createState() =>
      _FullscreenImageSate(url, index, nb, pictures);
}

class _FullscreenImageSate extends State<FullscreenImage> {
  String url;
  int index;
  final int nb;
  final List<Picture> pictures;
  bool left = false;
  double scale = minScale;
  Offset startOffset = Offset(0,0);
  Offset offset = Offset(0,0);
  Offset start = Offset(0,0);

  _FullscreenImageSate(this.url, this.index, this.nb, this.pictures);

  void updateUrl(int idx) {
    setState(() {
      url = pictures[idx].medium;
      index = idx;
    });
  }

  void update(double delta) {
    left = delta != 0;
  }

  void goto(Picture picture, int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FullscreenImage(picture.medium, index, nb, pictures)));
  }

  void goBack(Navigation n) {
    Widget w = n.getPrevious();
    Navigator.push(context, MaterialPageRoute(builder: (context) => w));
  }

  Widget wrapWidget(Widget w, Navigation n) {
    return GestureDetector(
        onHorizontalDragUpdate: (e) {
          if(scale != minScale){
            setState((){
              offset = Offset(startOffset.dx + start.dx - e.localPosition.dx, startOffset.dy + start.dy - e.localPosition.dy);
            });
          }else {
            update(e.delta.direction);
          }
        },
        onHorizontalDragStart: (e){
          setState((){
            start = e.localPosition;
            startOffset = Offset(offset.dx, offset.dy);
          });
        },
        onHorizontalDragEnd: (e) {
          if(scale != minScale){
            return;
          }
          if (left && index < nb) {
            updateUrl(index + 1);
          }
          if (!left && index > 0) {
            updateUrl(index - 1);
          }
        },
        onDoubleTap: () {
          if(scale > minScale){
            setState((){
              scale = minScale;
            });
          }else {
            setState((){
              scale = maxScale;
            });
          }
        },
        child: Transform.scale(
          scale: scale,
          origin: offset,
          child: w,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Navigation>(builder: (ctx, nav, child) {
      return Scaffold(
          appBar: AppBar(
            title: Text("${index + 1} / $nb"),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => goBack(nav),
                icon: const Icon(Icons.close_fullscreen)),
          ),
          body: wrapWidget(Container(
              color: Colors.black, child: Center(child: FolderHelper().getImageNoFit(url))),nav));
    });
  }
}
