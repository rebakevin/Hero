import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth.dart';
import 'features/home/home.dart';
import 'features/notifications/notifications.dart';
import 'features/reports/reports.dart';

/// Rebuilds the whole app for the active account. The key discards every Cubit
/// and screen of the previous account, so nothing of theirs stays on show.
class HeroRoot extends StatelessWidget {
  const HeroRoot({
    super.key,
    required this.accountSessions,
    required this.appForSlot,
  });

  final AccountSessions accountSessions;
  final HeroApp Function(String slot) appForSlot;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      initialData: accountSessions.activeSlot,
      stream: accountSessions.activeSlotChanges(),
      builder: (context, snapshot) => KeyedSubtree(
        key: ValueKey(snapshot.requireData),
        child: appForSlot(snapshot.requireData),
      ),
    );
  }
}

class HeroApp extends StatelessWidget {
  const HeroApp({
    super.key,
    required this.accountSessions,
    required this.authRepository,
    required this.userRepository,
    required this.reportRepository,
    required this.voteRepository,
    required this.notificationRepository,
    required this.photoUrls,
    required this.photoPicker,
  });

  final AccountSessions accountSessions;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final ReportRepository reportRepository;
  final VoteRepository voteRepository;
  final NotificationRepository notificationRepository;
  final PhotoUrlResolver photoUrls;
  final PhotoPicker photoPicker;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: accountSessions),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: reportRepository),
        RepositoryProvider.value(value: voteRepository),
        RepositoryProvider.value(value: notificationRepository),
        RepositoryProvider.value(value: photoUrls),
        RepositoryProvider.value(value: photoPicker),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(
          authRepository: authRepository,
          userRepository: userRepository,
        ),
        child: MaterialApp(
          title: 'Hero',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: AuthGate(
            authenticatedBuilder: (context, user) => HomeShell(user: user),
          ),
        ),
      ),
    );
  }
}
