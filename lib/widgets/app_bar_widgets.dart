import 'package:flutter/material.dart';

PreferredSizeWidget homeAppBarWidget(BuildContext context,
    {bool mayGoBack = false}) {
  return AppBar(
      automaticallyImplyLeading: mayGoBack,
      actions: [Image.asset('assets/images/central_elem_logo.png')]);
}

PreferredSizeWidget authenticationAppBarWidget() {
  return AppBar(
    elevation: 0,
    automaticallyImplyLeading: false,
  );
}
