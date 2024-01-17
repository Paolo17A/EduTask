import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUserTypeNotifier extends StateNotifier<String> {
  CurrentUserTypeNotifier() : super('');

  void setCurrentUserType(String currentUserType) {
    state = currentUserType;
  }
}

final currentUserTypeProvider =
    StateNotifierProvider<CurrentUserTypeNotifier, String>(
        (ref) => CurrentUserTypeNotifier());
