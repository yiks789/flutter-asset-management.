import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/pagination/page_delay.dart';
import 'package:flutter_application_1/core/pagination/pagination.dart';

const TimedPageDelay zeroPageDelay = TimedPageDelay(Duration.zero);
const Duration zeroSearchDebounce = Duration.zero;

/// Delay yang bisa diselesaikan manual untuk mengamati loader.
class ManualPageDelay implements PageDelay {
  final Completer<void> _completer = Completer<void>();

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> wait(PageRequest request) {
    assert(request.pageSize > 0);
    return _completer.future;
  }
}

Future<void> dragUp(
  WidgetTester tester,
  Finder scrollable, {
  double distance = 1400,
}) async {
  await tester.drag(scrollable, Offset(0, -distance));
  await tester.pump();
}
