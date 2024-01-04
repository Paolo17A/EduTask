import 'package:edutask/util/color_util.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget homeAppBarWidget(BuildContext context,
    {required Color backgroundColor, bool mayGoBack = false}) {
  return AppBar(
      automaticallyImplyLeading: mayGoBack,
      backgroundColor: backgroundColor,
      actions: [Image.asset('assets/images/central_elem_logo.png')]);
}

PreferredSizeWidget authenticationAppBarWidget() {
  return AppBar(
    elevation: 0,
    automaticallyImplyLeading: false,
    backgroundColor: CustomColors.verySoftOrange,
  );
}
