import 'package:flutter/material.dart';

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
          onPressed: () {}, child: interText('Forgot Password?', fontSize: 15)),
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
