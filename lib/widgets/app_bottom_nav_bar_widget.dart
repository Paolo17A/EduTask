import 'package:flutter/material.dart';

import '../util/navigator_util.dart';

Widget userBottomNavBar(BuildContext context,
    {required int index,
    required String userType,
    required Color backgroundColor}) {
  return BottomNavigationBar(
    currentIndex: index,
    items: [
      BottomNavigationBarItem(
          backgroundColor: backgroundColor,
          icon: blackIcon(Icons.home),
          label: 'Home'),
      BottomNavigationBarItem(
          backgroundColor: backgroundColor,
          icon: blackIcon(Icons.class_sharp),
          label: 'Sections'),
      BottomNavigationBarItem(
          backgroundColor: backgroundColor,
          icon: blackIcon(Icons.calendar_today),
          label: 'Calendar'),
      BottomNavigationBarItem(
          backgroundColor: backgroundColor,
          icon: blackIcon(Icons.auto_graph),
          label: 'Submissions'),
      BottomNavigationBarItem(
          backgroundColor: backgroundColor,
          icon: blackIcon(Icons.message),
          label: 'Messages')
    ],
    onTap: (tappedIndex) {
      if (tappedIndex == index) {
        return;
      }
      if (userType == 'TEACHER') {
        switch (tappedIndex) {
          case 0:
            Navigator.of(context).pushNamed(NavigatorRoutes.teacherHome);
            break;
          case 1:
            Navigator.of(context)
                .pushNamed(NavigatorRoutes.teacherHandledSections);
            break;
        }
      } else if (userType == 'STUDENT') {
        switch (tappedIndex) {
          case 0:
            Navigator.of(context).pushNamed(NavigatorRoutes.studentHome);
            break;
          case 1:
            Navigator.of(context).pushNamed(NavigatorRoutes.studentLessons);
            break;
          case 3:
            Navigator.of(context)
                .pushNamed(NavigatorRoutes.studentSubmittables);
        }
      }
    },
  );
}

Widget blackIcon(IconData iconData) {
  return Icon(iconData, color: Colors.black);
}
