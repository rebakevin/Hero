import 'package:flutter/material.dart';

import '../../auth/auth.dart';
import '../../notifications/notifications.dart';
import '../../profile/profile.dart';
import '../../reports/reports.dart';

/// Role-based bottom navigation. Students get Home, My reports, Alerts and
/// Profile; staff get Needs action, All reports and Profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // Built on every build so a renamed user reaches the tabs; the tab widgets keep their state.
  List<_Tab> _tabs(AppUser user) => switch (user.role) {
    Role.student => [
      _Tab(
        'Home',
        const Icon(Icons.home_rounded),
        ReportsTab(user: user, scope: ReportListScope.everyone),
      ),
      _Tab(
        'My reports',
        const Icon(Icons.assignment_rounded),
        ReportsTab(user: user, scope: ReportListScope.mine),
      ),
      _Tab(
        'Alerts',
        const UnreadBadge(child: Icon(Icons.notifications_rounded)),
        NotificationsTab(user: user),
      ),
      _Tab(
        'Profile',
        const Icon(Icons.person_rounded),
        ProfileScreen(user: user),
      ),
    ],
    Role.staff => [
      _Tab(
        'Needs action',
        const Icon(Icons.pending_actions_rounded),
        ReportsTab(user: user, scope: ReportListScope.needsAction),
      ),
      _Tab(
        'All reports',
        const Icon(Icons.assignment_rounded),
        ReportsTab(user: user, scope: ReportListScope.everyone),
      ),
      _Tab(
        'Profile',
        const Icon(Icons.person_rounded),
        ProfileScreen(user: user),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs(widget.user);
    final shell = Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [for (final tab in tabs) tab.body],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: tab.icon, label: tab.label),
        ],
      ),
    );
    // Only students are notified; the scope also feeds the Alerts badge.
    return widget.user.isStaff
        ? shell
        : NotificationsScope(user: widget.user, child: shell);
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.body);

  final String label;
  final Widget icon;
  final Widget body;
}
