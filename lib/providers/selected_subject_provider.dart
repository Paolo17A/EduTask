import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedSubjectNotifier extends StateNotifier<String> {
  SelectedSubjectNotifier() : super('');

  void setSelectedSubject(String subject) {
    state = subject;
  }
}

final selectedSubjectProvider =
    StateNotifierProvider<SelectedSubjectNotifier, String>(
        (ref) => SelectedSubjectNotifier());
