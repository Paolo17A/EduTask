import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutask/util/navigator_util.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'custom_text_widgets.dart';

Widget authenticationIcon(BuildContext context, {required IconData iconData}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.grey),
      child: Transform.scale(
          scale: 5, child: Icon(iconData, color: Colors.black)));
}

Widget logInBottomRow(BuildContext context, {required Function onRegister}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: interText('< Back', fontSize: 15)),
      TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(NavigatorRoutes.resetPassword),
          child: interText('Forgot Password?', fontSize: 15)),
      TextButton(
          onPressed: () => onRegister(),
          child: interText('Register', fontSize: 15))
    ],
  );
}

Widget buildProfileImageWidget(
    {required String profileImageURL, double radius = 40}) {
  return Column(children: [
    profileImageURL.isNotEmpty
        ? CircleAvatar(
            radius: radius, backgroundImage: NetworkImage(profileImageURL))
        : CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: radius * 1.5,
              color: Colors.black,
            )),
  ]);
}

Widget welcomeWidgets(
    {required String userType, required String profileImageURL}) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        all10Pix(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            interText('WELCOME,\n$userType', fontSize: 30),
            buildProfileImageWidget(profileImageURL: profileImageURL)
          ]),
        ),
        Container(height: 15, color: Colors.grey)
      ],
    ),
  );
}

Widget userRecordEntry(
    {required DocumentSnapshot userDoc,
    required Color color,
    required Function onTap}) {
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  String formattedName = '${userData['firstName']} ${userData['lastName']}';
  String profileImageURL = userData['profileImageURL'];
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      color: color,
      height: 50,
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        buildProfileImageWidget(profileImageURL: profileImageURL, radius: 15),
        const Gap(16),
        interText(formattedName, fontSize: 16)
      ]),
    ),
  );
}
