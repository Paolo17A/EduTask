import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../util/navigator_util.dart';

Widget teacherBottomNavBar(BuildContext context, {required int index}) {
  return BottomAppBar(
    color: CustomColors.veryDarkGrey,
    height: 85,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 0
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.teacherHome),
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
          width: MediaQuery.of(context).size.width * 0.45,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 1
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.teacherHandledSections),
                  icon: Icon(Icons.class_rounded,
                      color: index == 1
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('SECTIONS',
                  fontSize: 8,
                  color:
                      index == 1 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),
        /*SizedBox(
          width: MediaQuery.of(context).size.width * 0.18,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.calendar_month,
                      color: index == 2
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('CALENDAR',
                  fontSize: 8,
                  color:
                      index == 2 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),*/
        /*SizedBox(
          width: MediaQuery.of(context).size.width * 0.18,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.auto_graph,
                      color: index == 3
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('PROGRESS',
                  fontSize: 8,
                  color:
                      index == 3 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),*/
        /*SizedBox(
          width: MediaQuery.of(context).size.width * 0.18,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.message_rounded,
                      color: index == 4
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('MESSAGES',
                  fontSize: 8,
                  color:
                      index == 4 ? Colors.yellow : CustomColors.veryLightGrey)
            ],
          ),
        ),*/
      ],
    ),
  );
}

Widget adminBottomNavBar(BuildContext context, {required int index}) {
  return BottomAppBar(
    color: CustomColors.veryDarkGrey,
    height: 85,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
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
        /*SizedBox(
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
        ),*/
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
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
          width: MediaQuery.of(context).size.width * 0.2,
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
          width: MediaQuery.of(context).size.width * 0.25,
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
          width: MediaQuery.of(context).size.width * 0.25,
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
          width: MediaQuery.of(context).size.width * 0.2,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => index == 3
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.studentProfile),
                  icon: Icon(Icons.person,
                      color: index == 3
                          ? Colors.yellow
                          : CustomColors.veryLightGrey)),
              interText('PROFILE',
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
