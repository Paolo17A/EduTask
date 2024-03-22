import 'package:edutask/util/color_util.dart';
import 'package:flutter/material.dart';

class BoolAnswerButton extends StatefulWidget {
  final bool boolVal;
  final String answer;
  final void Function() onTap;
  final bool isSelected;
  const BoolAnswerButton(
      {required this.boolVal,
      required this.answer,
      required this.onTap,
      required this.isSelected,
      super.key});

  @override
  State<BoolAnswerButton> createState() => _BoolAnswerButtonState();
}

class _BoolAnswerButtonState extends State<BoolAnswerButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        //width: MediaQuery.sizeOf(context).width * 0.30,
        height: 70,
        child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(
                    side: BorderSide(color: CustomColors.softOrange, width: 4)),
                backgroundColor:
                    widget.isSelected ? CustomColors.softOrange : Colors.white),
            child: Text(
              widget.answer,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )),
      ),
    );
  }
}
