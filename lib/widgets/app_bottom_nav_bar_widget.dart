import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
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
      switch (tappedIndex) {
        case 0:
          Navigator.of(context).pushNamed(NavigatorRoutes.teacherHome);
          break;
        case 1:
          Navigator.of(context)
              .pushNamed(NavigatorRoutes.teacherHandledSections);
          break;
      }
    },
  );
}

Widget adminBottomNavBar(BuildContext context, {required int index}) {
  return BottomAppBar(
    color: CustomColors.veryDarkGrey,
    height: 85,
    child: Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 0
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.adminHome),
                  icon: Icon(Icons.home,
                      color: index == 0
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('HOME',
                  fontSize: 8,
                  color:
                      index == 0 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.calendar_month,
                      color: index == 1
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('CALENDAR',
                  fontSize: 8,
                  color:
                      index == 1 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 2
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.adminMaterials),
                  icon: Icon(Icons.edit,
                      color: index == 2
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('MATERIALS',
                  fontSize: 8,
                  color:
                      index == 2 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
      ],
    ),
  );
}

Widget clientBottomNavBar(BuildContext context, {required int index}) {
  return BottomAppBar(
    color: CustomColors.veryDarkGrey,
    height: 85,
    notchMargin: 0,
    shape: CircularNotchedRectangle(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 0
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.studentHome),
                  icon: Icon(Icons.home,
                      color: index == 0
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('HOME',
                  fontSize: 8,
                  color:
                      index == 0 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 1
                      ? null
                      : Navigator.of(context).pushNamed(
                          NavigatorRoutes.studentMaterialsSubjectSelect),
                  icon: Icon(Icons.library_books_rounded,
                      color: index == 1
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('MATERIALS',
                  fontSize: 8,
                  color:
                      index == 1 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 2
                      ? null
                      : Navigator.of(context).pushNamed(
                          NavigatorRoutes.studentProgressSubjectSelect),
                  icon: Icon(Icons.auto_graph_rounded,
                      color: index == 2
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('GRADES',
                  fontSize: 8,
                  color:
                      index == 2 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.message_rounded,
                      color: index == 3
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('MESSAGES',
                  fontSize: 8,
                  color:
                      index == 3 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
      ],
    ),
  );
}

Widget customBottomButton(BuildContext context,
    {required double width,
    required int currentIndex,
    required int thisIndex}) {
  return SizedBox(
    width: width,
    child: Column(
      children: [
        IconButton(
            onPressed: () => currentIndex == thisIndex
                ? null
                : Navigator.of(context).pushNamed(NavigatorRoutes.studentHome),
            icon: Icon(Icons.home,
                color: currentIndex == thisIndex
                    ? Colors.yellow
                    : CustomColors.veryLightGrey)),
        interText('HOME',
            fontSize: 8,
            color: currentIndex == thisIndex
                ? Colors.yellow
                : CustomColors.veryLightGrey)
      ],
    ),
  );
}

Widget blackIcon(IconData iconData) {
  return Icon(iconData, color: Colors.black);
}
