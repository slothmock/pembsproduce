class AppStrings {
  // Most-used app strings
  static String get appTitle => "PembsProduce";
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
