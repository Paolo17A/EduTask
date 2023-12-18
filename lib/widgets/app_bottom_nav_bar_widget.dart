import 'package:flutter/material.dart';

import '../util/navigator_util.dart';

Widget userBottomNavBar(BuildContext context,
    {required int index, required String userType}) {
  return BottomNavigationBar(
    currentIndex: index,
    items: [
      BottomNavigationBarItem(
          backgroundColor: Colors.grey,
          icon: blackIcon(Icons.home),
          label: 'Home'),
      BottomNavigationBarItem(
          backgroundColor: Colors.grey,
          icon: blackIcon(Icons.class_sharp),
          label: 'Sections'),
      BottomNavigationBarItem(
          backgroundColor: Colors.grey,
          icon: blackIcon(Icons.calendar_today),
          label: 'Calendar'),
      BottomNavigationBarItem(
          backgroundColor: Colors.grey,
          icon: blackIcon(Icons.auto_graph),
          label: 'Submissions'),
      BottomNavigationBarItem(
          backgroundColor: Colors.grey,
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
        }
      }
    },
  );
}

Widget blackIcon(IconData iconData) {
  return Icon(iconData, color: Colors.black);
}
