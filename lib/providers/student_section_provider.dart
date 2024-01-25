import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentSectionNotifier extends StateNotifier<String> {
  StudentSectionNotifier() : super('');
  void setStudentSection(String studentSection) {
    state = studentSection;
  }
}

final studentSectionProvider =
    StateNotifierProvider<StudentSectionNotifier, String>(
        (ref) => StudentSectionNotifier());
