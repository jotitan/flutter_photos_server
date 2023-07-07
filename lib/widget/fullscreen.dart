import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:photos_server_flutter/model.dart';
import 'package:photos_server_flutter/provider/images_provider.dart';
import 'package:photos_server_flutter/provider/navigation_provider.dart';
import 'package:provider/provider.dart';

const minScale = 1.0;
const maxScale = 2.5;
const hdScale = 5.0;

class FullscreenImage extends StatefulWidget {
  final String url;
  final String urlHD;
  final bool isPortrait;
  final int index;
  final int nb;
  final List<Picture> pictures;

  const FullscreenImage(this.url, this.urlHD,this.isPortrait, this.index, this.nb, this.pictures,
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
  Offset startOffset = const Offset(0, 0);
  Offset offset = const Offset(0, 0);
  Offset start = const Offset(0, 0);

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
                FullscreenImage(picture.medium, picture.high,picture.height > picture.width, index, nb, pictures)));
  }

  void goBack(Navigation n) {
    Widget w = n.getPrevious();
    Navigator.push(context, MaterialPageRoute(builder: (context) => w));
  }

  void toggleZoom(){
    if (scale == maxScale) {
      zoom1X();
    } else {
      zoom2X();
    }
  }

  void toggleHDZoom(){
    if (scale == hdScale) {
      zoom1X();
    } else {
      zoom5X();
    }
  }

  void zoom1X(){
    setState(() {
      start=Offset(0,0);
      startOffset=Offset(0,0);
      offset=Offset(0,0);
      scale = minScale;
    });
  }

  void zoom2X() {
    setState(() {
      scale = maxScale;
    });
  }

  void zoom5X(){
    setState((){
      scale = hdScale;
    });
  }

  List<int> getBounds(bool isPortrait, double width){
    int lowBound = (width/-2).toInt();
    int highBound = (width/2).toInt();
    if(scale == maxScale){
      if(isPortrait){
        return [lowBound,highBound,-230,230];
      }else{
        return [lowBound, highBound, 0, 0];
      }
    }else{
      if(isPortrait){
        return [lowBound,highBound,-255,255];
      }else{
        return [lowBound, highBound, -70, 70];
      }
    }
  }

  Widget wrapWidget(double width, double height, Widget w, Navigation n) {
    return GestureDetector(
        onHorizontalDragUpdate: (e) {
          if (scale != minScale) {
            List<int> bounds = getBounds(pictures[index].height > pictures[index].width, width);
            setState(() {
              var x = startOffset.dx + start.dx - e.localPosition.dx;
              var y = startOffset.dy + start.dy - e.localPosition.dy;
              //print("MOVE $x $y $width $height ${widget.isPortrait} ${pictures[index].height}  ${pictures[index].width}");

              offset = Offset(x, y);
            });
          } else {
            update(e.delta.direction);
          }
        },
        onHorizontalDragStart: (e) {
          setState(() {
            start = e.localPosition;
            startOffset = Offset(offset.dx, offset.dy);
          });
        },
        onHorizontalDragEnd: (e) {
          if (scale != minScale) {
            List<int> bounds = getBounds(pictures[index].height > pictures[index].width, width);
            if(offset.dx < bounds[0]){
              setState((){
                offset = Offset(bounds[0].toDouble(), offset.dy);
              });
            }
            if(offset.dx > bounds[1]){
              setState((){
                offset = Offset(bounds[1].toDouble(), offset.dy);
              });
            }
            if(offset.dy < bounds[2]){
              setState((){
                offset = Offset(offset.dx, bounds[2].toDouble());
              });
            }
            if(offset.dy > bounds[3]){
              setState((){
                offset = Offset(offset.dx, bounds[3].toDouble());
              });
            }
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
          toggleZoom();
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
            actions: [
              Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      toggleZoom();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      primary: scale == maxScale ? Colors.orange : Colors.blue,
                    ),
                    child:
                        const Text("x2", style: TextStyle(color: Colors.white)),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      toggleHDZoom();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      primary: scale == hdScale ? Colors.orange : Colors.blue,
                    ),
                    child:
                    const Text("x5", style: TextStyle(color: Colors.white)),
                  )),
            ],
            leading: IconButton(
                onPressed: () => goBack(nav), icon: const Icon(Icons.close)),
          ),
          body: wrapWidget(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
              Container(
                  color: Colors.black,
                  child: Center(child: FolderHelper().getImageNoFit(scale == hdScale ? widget.urlHD : url))),
              nav));
    });
  }
}
