
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
  final int index;
  final int nb;

  ImageDto(this.littleUrl, this.fullscreenUrl, this.index, this.nb);
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