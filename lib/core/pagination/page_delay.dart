import 'pagination.dart';

/// Kontrak jeda/pengambilan halaman. Bisa diganti fetcher API di kemudian hari.
abstract interface class PageDelay {
  Future<void> wait(PageRequest request);
}

/// Jeda in-memory yang bisa disuntikkan, termasuk [Duration.zero] untuk test.
class TimedPageDelay implements PageDelay {
  const TimedPageDelay([this.duration = kPageLoadDelay]);

  final Duration duration;

  @override
  Future<void> wait(PageRequest request) {
    assert(request.pageSize > 0);
    if (duration <= Duration.zero) {
      return Future<void>.value();
    }
    return Future<void>.delayed(duration);
  }
}

const TimedPageDelay kDefaultPageDelay = TimedPageDelay();
