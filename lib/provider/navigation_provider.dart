import 'package:flutter/material.dart';

class Navigation extends ChangeNotifier {
  late Widget previous;
  late DateTime currentDate = DateTime.now();
  int currentTab = 0;

  void setPrevious(Widget p) {
    previous = p;
  }

  Widget getPrevious() {
    return previous;
  }

  void setCurrentDate(DateTime date){
    currentDate = date;
    notifyListeners();
  }

}
