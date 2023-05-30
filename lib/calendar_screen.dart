import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photos_server_flutter/list_photos.dart';
import 'package:photos_server_flutter/main.dart';
import 'package:photos_server_flutter/provider/images_provider.dart';
import 'package:photos_server_flutter/provider/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class PhotosCalendar extends StatefulWidget {
  @override
  State<PhotosCalendar> createState() => CalendarState();
}

class CalendarState extends State<PhotosCalendar> {
  CalendarState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataSingletonProvider>(
        builder: (ctx2, singleton, child2) => Consumer<Navigation>(
            builder: (ctx, nav, child) => Scaffold(
                appBar: AppBar(
                  title: const Text("Calendrier"),
                  automaticallyImplyLeading: false,
                ),
                body: FutureBuilder<Map<DateTime, int>>(
                  future: singleton.allDates,
                  builder: (context, snapshot) => snapshot.hasData
                      ? TableCalendar(
                          availableCalendarFormats: const {
                            CalendarFormat.month: "Month"
                          },
                          firstDay: DateTime.utc(1950, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: nav.currentDate,
                          currentDay: nav.currentDate,
                          locale: 'fr_FR',
                          calendarFormat: CalendarFormat.month,
                          onDaySelected: (selected, focused) {
                            nav.setCurrentDate(selected);
                            int? nb =
                                snapshot.hasData ? snapshot.data![selected] : 0;
                            if (nb != null && nb > 0) {
                              String date = FolderHelper.formatDate(selected);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PicturesOfFolderView("$date ($nb)", date,
                                              HomePage("Photos server", null),
                                              loadByDate: true)));
                            }
                          },
                          eventLoader: (date) {
                            int? nb =
                                snapshot.hasData ? snapshot.data![date] : 0;
                            return nb != null && nb > 0
                                ? List.generate(max(1, log(nb / 4).floor()),
                                    (index) => true)
                                : [];
                          },
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: false,
                          ),
                        )
                      : const Text("loading dates"),
                ))));
  }
}
