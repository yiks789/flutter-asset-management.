/// Data pengguna yang disimpan dalam sesi login in-memory.
class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.division,
  });

  static const AuthUser demo = AuthUser(
    name: 'Rina Putri',
    email: 'rina@demo.test',
    division: 'Finance',
  );

  final String name;
  final String email;
  final String division;
}
