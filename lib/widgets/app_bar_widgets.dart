import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget homeAppBarWidget(BuildContext context,
    {bool mayGoBack = false}) {
  return AppBar(
    automaticallyImplyLeading: mayGoBack,
    actions: [
      all10Pix(
        child: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.popUntil(context, (route) => route.isFirst);
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: interText('LOG-OUT')),
      )
    ],
  );
}

PreferredSizeWidget authenticationAppBarWidget() {
  return AppBar(
    elevation: 0,
    automaticallyImplyLeading: false,
  );
}
