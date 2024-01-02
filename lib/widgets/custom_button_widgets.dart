import 'package:edutask/widgets/custom_padding_widgets.dart';
import 'package:edutask/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

Widget welcomeButton(BuildContext context,
    {required Function onPress,
    required IconData iconData,
    required String label}) {
  return all20Pix(
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      height: 150,
      child: ElevatedButton(
        onPressed: () => onPress(),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        child: Column(
          children: [
            Expanded(
                child: Transform.scale(
                    scale: 5, child: Icon(iconData, color: Colors.black))),
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
    double? width,
    double? height,
    Color color = Colors.black}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: interText(label,
          fontWeight: FontWeight.bold,
          color: color,
          textAlign: TextAlign.center),
    ),
  );
}
