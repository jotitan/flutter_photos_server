import 'package:flutter/material.dart';

class Navigation extends ChangeNotifier {
  late Widget previous;
  late DateTime currentDate = DateTime.now();
  late DateTime displayedDate = DateTime.now();
  int currentTab = 0;
  ScrollController scroller = ScrollController();
  String currentFolder = "";


  void setPrevious(Widget p) {
    previous = p;
  }

  Widget getPrevious() {
    return previous;
  }

  ScrollController newScroller(String folder){
    double initialOffset = 0;
    if(folder.compareTo(currentFolder) == 0 ){
      initialOffset = scroller.offset;
    }
    currentFolder = folder;
    scroller = ScrollController(initialScrollOffset: initialOffset);

    return scroller;
  }

  void setCurrentDate(DateTime date){
    currentDate = date;
    displayedDate = date;
    notifyListeners();
  }

  void setDisplayedDate(DateTime date){
    displayedDate = date;
    notifyListeners();
  }

}
