
import 'package:flutter/cupertino.dart';

class ItemFolderPhoto {
  final String name;
  final String path;

  ItemFolderPhoto(this.name, this.path);

  buildTitle(BuildContext context) => Text(name);
}

class ImageDto {
  final String littleUrl;
  final String fullscreenUrl;
  final String hdUrl;
  final int index;
  final int nb;
  final int width;
  final int height;

  ImageDto(this.littleUrl, this.fullscreenUrl, this.hdUrl, this.index, this.width, this.height, this.nb);

  bool isPortrait(){
    return height / width > 1;
  }
}

class Picture {
  final String low;
  final String medium;
  final String high;
  final int width;
  final int height;
  final String date;

  Picture(this.low, this.medium, this.high, this.width, this.height, this.date);

  factory Picture.fromJSON(Map<String, dynamic> json) {
    return Picture(json["ThumbnailLink"], json["ImageLink"], json["HdLink"],
        json["Width"], json["Height"], json["Date"]);
  }
}

class NbPhotosByDate {
  final DateTime date;
  final int nb;

  NbPhotosByDate(this.date, this.nb);

  factory NbPhotosByDate.fromJSON(Map<String, dynamic> m){
    return NbPhotosByDate(DateTime.parse(m["Date"]), m["Nb"]);
  }
}

class Folder {
  final String name;
  final String link;
  final bool hasImages;

  final List<Folder> children;

  Folder(this.name, this.link, this.hasImages, this.children);

  factory Folder.fromJSON(Map<String, dynamic> json) {
    var l = json["Children"] as List;
    var children = l.map((sub) => Folder.fromJSON(sub)).toList();
    children.sort((a, b) => a.name.compareTo(b.name));

    return Folder(json["Name"], json["Link"], json["HasImages"], children);
  }
}