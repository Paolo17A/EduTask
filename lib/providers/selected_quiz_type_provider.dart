import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedQuizTypeNotifier extends StateNotifier<String> {
  SelectedQuizTypeNotifier() : super('');

  void setSelectedQuizType(String quizType) {
    state = quizType;
  }
}

final selectedQuizTypeProvider =
    StateNotifierProvider<SelectedQuizTypeNotifier, String>(
        (ref) => SelectedQuizTypeNotifier());
