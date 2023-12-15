import 'package:flutter/material.dart';

class EduTaskTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final TextInputType textInputType;
  final Icon? displayPrefixIcon;
  final bool enabled;
  final bool hasSearchButton;
  final Function? onSearchPress;
  const EduTaskTextField({
    super.key,
    required this.text,
    required this.controller,
    required this.textInputType,
    required this.displayPrefixIcon,
    this.enabled = true,
    this.hasSearchButton = false,
    this.onSearchPress,
  });

  @override
  State<EduTaskTextField> createState() => _EduTaskTextFieldState();
}

class _EduTaskTextFieldState extends State<EduTaskTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.textInputType == TextInputType.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        enabled: widget.enabled,
        controller: widget.controller,
        obscureText: isObscured,
        cursorColor: Colors.black,
        onSubmitted: (value) {
          if (widget.onSearchPress != null) {
            widget.onSearchPress!();
          }
        },
        style: TextStyle(color: Colors.black.withOpacity(0.9)),
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: widget.text,
            labelStyle: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontStyle: FontStyle.italic),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white.withOpacity(0.4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.black, width: 3.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            prefixIcon: widget.displayPrefixIcon,
            suffixIcon: widget.textInputType == TextInputType.visiblePassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black.withOpacity(0.6),
                    ))
                : widget.hasSearchButton && widget.onSearchPress != null
                    ? ElevatedButton(
                        onPressed: () {
                          if (widget.controller.text.isEmpty) return;
                          widget.onSearchPress!();
                        },
                        child: const Icon(Icons.search))
                    : null),
        keyboardType: widget.textInputType,
        maxLines: widget.textInputType == TextInputType.multiline ? 6 : 1);
  }
}
