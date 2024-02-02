import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/custom_miscellaneous_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../util/color_util.dart';

Drawer appDrawer(BuildContext context,
    {required String userType,
    bool isHome = false,
    Color backgroundColor = CustomColors.veryDarkGrey,
    String profileImageURL = ''}) {
  return Drawer(
    backgroundColor: backgroundColor,
    child: Column(
      children: [
        DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                buildProfileImageWidget(
                    profileImageURL: profileImageURL, radius: 52)
              ]),
              Gap(8),
            ],
          ),
          decoration: BoxDecoration(color: backgroundColor),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Gap(20),
              _home(context, userType: userType, isHome: isHome),
              _profile(context, userType: userType),
              if (userType == 'TEACHER') _lessonMaterials(context),
              _settings(context)
            ],
          ),
        ),
        _logOutButton(context)
      ],
    ),
  );
}

Widget _home(BuildContext context,
    {required String userType, required bool isHome}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading: const Icon(Icons.home, color: CustomColors.veryLightGrey),
      title: interText('HOME', color: CustomColors.veryLightGrey),
      onTap: () {
        Navigator.of(context).pop();
        if (isHome) {
          return;
        }
        if (userType == 'ADMIN') {
          Navigator.of(context).pushReplacementNamed(NavigatorRoutes.adminHome);
        } else if (userType == 'TEACHER') {
          Navigator.of(context)
              .pushReplacementNamed(NavigatorRoutes.teacherHome);
        } else if (userType == 'STUDENT') {
          Navigator.of(context)
              .pushReplacementNamed(NavigatorRoutes.studentHome);
        }
      },
    ),
  );
}

Widget _profile(BuildContext context, {required String userType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading: const Icon(Icons.person, color: CustomColors.veryLightGrey),
      title: interText('PROFILE', color: CustomColors.veryLightGrey),
      onTap: () {
        Navigator.of(context).pop();

        if (userType == 'ADMIN') {
          Navigator.of(context).pushNamed(NavigatorRoutes.adminProfile);
        } else if (userType == 'TEACHER') {
          Navigator.of(context).pushNamed(NavigatorRoutes.teacherProfile);
        } else if (userType == 'STUDENT') {
          Navigator.of(context).pushNamed(NavigatorRoutes.studentProfile);
        }
      },
    ),
  );
}

Widget _lessonMaterials(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading:
          const Icon(Icons.star_rounded, color: CustomColors.veryLightGrey),
      title: interText('LESSON MATERIALS', color: CustomColors.veryLightGrey),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(NavigatorRoutes.lessonPlan);
      },
    ),
  );
}

Widget _settings(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading: const Icon(Icons.settings, color: CustomColors.veryLightGrey),
      title: interText('SETTINGS', color: CustomColors.veryLightGrey),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(NavigatorRoutes.changePassword);
      },
    ),
  );
}

Widget _logOutButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      decoration: BoxDecoration(
          color: CustomColors.veryLightGrey,
          borderRadius: BorderRadius.circular(50)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.black),
        title: Center(child: interText('LOG-OUT', color: Colors.black)),
        onTap: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        },
      ),
    ),
  );
}
