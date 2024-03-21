class AppStrings {
  // Most-used app strings
  static const String appTitle = "PembsProduce";

  static const String loginStr = "login";

  static const String email = "email";

  static const String emailInvalid = "Email Invalid";
  static const String passInvalid = "Password Invalid";

  // App routes
  static const String loginRoute = '/login';
  static const String mapRoute = '/shop_map';
  static const String favesRoute = '/favourites';
  static const String profileRoute = '/profile';
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
