import 'package:edutask/util/color_util.dart';
import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../util/navigator_util.dart';

Widget welcomeButton(BuildContext context,
    {required Function onPress,
    required IconData iconData,
    required String label}) {
  return all20Pix(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 120,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(
            color: CustomColors.veryDarkGrey,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(1, 2))
      ]),
      child: ElevatedButton(
        onPressed: () => onPress(),
        style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.veryLightGrey,
            shadowColor: CustomColors.veryDarkGrey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        child: Column(
          children: [
            Expanded(
                child: Transform.scale(
                    scale: 4, child: Icon(iconData, color: Colors.black))),
            interText(label,
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)
          ],
        ),
      ),
    ),
  );
}

Widget ovalButton(String label,
    {required Function onPress,
    required Color backgroundColor,
    double? width,
    double? height,
    Color color = Colors.black}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: interText(label,
          fontWeight: FontWeight.bold,
          color: color,
          textAlign: TextAlign.center),
    ),
  );
}

Widget homeButton(BuildContext context,
    {required String label, required Function onPress}) {
  return all10Pix(
      child: ovalButton(label,
          onPress: onPress,
          width: MediaQuery.of(context).size.width * 0.75,
          height: 125,
          backgroundColor: CustomColors.moderateCyan));
}

Widget studentSubmittablesButton(BuildContext context,
    {Color backgroundColor = CustomColors.veryLightGrey,
    bool doNothing = false}) {
  return SizedBox(
    width: 70,
    height: 70,
    child: ElevatedButton(
        onPressed: () => doNothing == true
            ? null
            : Navigator.of(context)
                .pushNamed(NavigatorRoutes.studentSubmittables),
        style: ElevatedButton.styleFrom(
            shape: CircleBorder(
                side: BorderSide(color: CustomColors.veryDarkGrey, width: 4)),
            backgroundColor: backgroundColor),
        child: Transform.scale(
          scale: 1.5,
          child: Icon(
            Icons.upload,
            color: CustomColors.veryDarkGrey,
          ),
        )),
  );
}
