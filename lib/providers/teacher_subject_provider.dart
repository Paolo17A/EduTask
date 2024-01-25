import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherSubjectNotifier extends StateNotifier<String> {
  TeacherSubjectNotifier() : super('');

  void setTeacherSubject(String subject) {
    state = subject;
  }
}

final teacherSubjectProvider =
    StateNotifierProvider<TeacherSubjectNotifier, String>(
        (ref) => TeacherSubjectNotifier());
