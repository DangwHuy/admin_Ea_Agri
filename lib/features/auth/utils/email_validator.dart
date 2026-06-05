class EmailValidator {
  static bool isValid(String email) {
    if (email.trim().isEmpty) return false;
    // Simple, pragmatic regex.
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email.trim());
  }
}
