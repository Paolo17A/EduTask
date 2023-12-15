import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

Text interText(String label,
    {double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: overflow,
    style: GoogleFonts.inter(
        fontSize: fontSize, fontWeight: fontWeight, color: color),
  );
}
