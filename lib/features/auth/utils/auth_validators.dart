/// Validasi ringan untuk form login, tanpa package tambahan.
String? validateEmail(String value) {
  final String email = value.trim();
  if (email.isEmpty) {
    return 'Email wajib diisi.';
  }
  final RegExp pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(email)) {
    return 'Format email tidak valid.';
  }
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) {
    return 'Password wajib diisi.';
  }
  return null;
}
