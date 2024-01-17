import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileImageNotifier extends StateNotifier<String> {
  ProfileImageNotifier() : super('');

  void setProfileImage(String profileImageURL) {
    state = profileImageURL;
  }
}

final profileImageProvider =
    StateNotifierProvider<ProfileImageNotifier, String>(
        (ref) => ProfileImageNotifier());
