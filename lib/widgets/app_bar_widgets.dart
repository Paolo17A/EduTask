import 'package:edutask/util/color_util.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget homeAppBarWidget(BuildContext context,
    {required Color backgroundColor,
    bool mayGoBack = false,
    List<Widget>? actions}) {
  return AppBar(
      automaticallyImplyLeading: mayGoBack,
      backgroundColor: backgroundColor,
      title: Center(
          child: Image.asset('assets/images/App Logo_EduTask Side-White.png',
              scale: 50)),
      actions: actions);
}

PreferredSizeWidget authenticationAppBarWidget() {
  return AppBar(
    elevation: 0,
    automaticallyImplyLeading: false,
    backgroundColor: CustomColors.veryDarkGrey,
    title: Center(
        child: Image.asset('assets/images/App Logo_EduTask Side-White.png',
            scale: 50)),
  );
}
