import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Drawer appDrawer(BuildContext context,
    {required String userType, required Color backgroundColor}) {
  return Drawer(
    backgroundColor: backgroundColor,
    child: Column(
      children: [
        Flexible(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Gap(20),
              _home(context, userType: userType),
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

Widget _home(BuildContext context, {required String userType}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading: const Icon(
        Icons.home,
        color: Colors.black,
      ),
      title: interText('HOME', color: Colors.black),
      onTap: () {
        Navigator.of(context).pop();
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
      leading: const Icon(
        Icons.person,
        color: Colors.black,
      ),
      title: interText('PROFILE', color: Colors.black),
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
      leading: const Icon(
        Icons.star_rounded,
        color: Colors.black,
      ),
      title: interText('LESSON MATERIALS', color: Colors.black),
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
      leading: const Icon(
        Icons.settings,
        color: Colors.black,
      ),
      title: interText('SETTINGS', color: Colors.black),
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
          color: Colors.black, borderRadius: BorderRadius.circular(50)),
      child: ListTile(
        leading: const Icon(Icons.logout),
        title: interText('LOG-OUT', color: Colors.white),
        onTap: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        },
      ),
    ),
  );
}
