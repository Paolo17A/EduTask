import 'dart:math';

class QuizTypes {
  static const String multipleChoice = 'MULTIPLE-CHOICE';
  static const String trueOrFalse = 'TRUE-FALSE';
  static const String identification = 'IDENTIFICATION';
}

String generateRandomHexString(int length) {
  final random = Random();
  final codeUnits = List.generate(length ~/ 2, (index) {
    return random.nextInt(255);
  });

  final hexString =
      codeUnits.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return hexString;
}
