import 'package:flutter/material.dart';

import '../../core/clock/app_clock.dart';
import '../../features/asset/data/asset_return_service.dart';
import '../../features/asset/pages/asset_list_page.dart';
import '../../features/asset/widgets/app_bottom_nav.dart';
import '../../features/history/pages/history_page.dart'
    show HistoryPage, kDefaultHistorySearchDebounce;
import '../../features/profile/pages/profile_page.dart';
import '../pagination/page_delay.dart';

/// Shell dengan IndexedStack agar state tiap tab tetap hidup saat berpindah.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.historyReturnService,
    this.historyClock,
    this.pageDelay = kDefaultPageDelay,
    this.historySearchDebounce = kDefaultHistorySearchDebounce,
  });

  final AssetReturnService? historyReturnService;
  final AppClock? historyClock;
  final PageDelay pageDelay;
  final Duration historySearchDebounce;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tabIndex = 0;

  void _changeTab(int index) {
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: <Widget>[
          AssetListPage(
            pageDelay: widget.pageDelay,
            searchDebounce: widget.historySearchDebounce,
          ),
          HistoryPage(
            returnService: widget.historyReturnService,
            clock: widget.historyClock,
            pageDelay: widget.pageDelay,
            searchDebounce: widget.historySearchDebounce,
          ),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        activeIndex: _tabIndex,
        onTap: _changeTab,
      ),
    );
  }
}
