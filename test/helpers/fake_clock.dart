import 'package:flutter_application_1/core/clock/app_clock.dart';

/// Jam tetap untuk test (18 Nov 2026 10:00 WIB lokal).
class FakeClock implements AppClock {
  FakeClock([DateTime? value]) : value = value ?? DateTime(2026, 11, 18, 10, 0);

  final DateTime value;

  @override
  DateTime now() => value;
}
