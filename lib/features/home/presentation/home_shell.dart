import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../auth/auth.dart';
import '../../profile/profile.dart';
import '../../reports/reports.dart';

/// Role-based bottom navigation. Needs action and Alerts are placeholders until
/// the staff workflow and notifications land.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<_Tab> _tabs = switch (widget.user.role) {
    Role.student => [
      _Tab(
        'Home',
        Icons.home_rounded,
        ReportsTab(user: widget.user, scope: ReportListScope.everyone),
      ),
      _Tab(
        'My reports',
        Icons.assignment_rounded,
        ReportsTab(user: widget.user, scope: ReportListScope.mine),
      ),
      const _Tab(
        'Alerts',
        Icons.notifications_rounded,
        EmptyState(
          icon: Icons.notifications_rounded,
          title: 'No alerts',
          message: 'Updates on your reports will appear here.',
        ),
      ),
      _Tab('Profile', Icons.person_rounded, ProfileScreen(user: widget.user)),
    ],
    Role.staff => [
      const _Tab(
        'Needs action',
        Icons.pending_actions_rounded,
        EmptyState(
          icon: Icons.inbox_rounded,
          title: 'Nothing needs action',
          message: 'New and in-progress reports will appear here.',
        ),
      ),
      _Tab(
        'All reports',
        Icons.assignment_rounded,
        ReportsTab(user: widget.user, scope: ReportListScope.everyone),
      ),
      _Tab('Profile', Icons.person_rounded, ProfileScreen(user: widget.user)),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [for (final tab in _tabs) tab.body],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.body);

  final String label;
  final IconData icon;
  final Widget body;
}
