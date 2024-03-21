class Validators {
  static bool emailValid(String? email) {
    if (email!.isEmpty) {
      return false;
    } else if (email
        .contains(r'^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$')) {
      return true;
    } else {
      return false;
    }
  }
}
