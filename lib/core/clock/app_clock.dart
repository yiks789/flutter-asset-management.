/// Jam yang bisa disuntikkan agar logika tanggal mudah dites.
abstract interface class AppClock {
  DateTime now();
}

/// Implementasi jam sistem untuk aplikasi nyata.
class SystemClock implements AppClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
