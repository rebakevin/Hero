import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../application/notifications_cubit.dart';
import '../domain/notification_repository.dart';

/// Provides the user's [NotificationsCubit] to the tabs and the unread badge below it.
class NotificationsScope extends StatelessWidget {
  const NotificationsScope({
    super.key,
    required this.user,
    required this.child,
  });

  final AppUser user;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsCubit(
        repository: context.read<NotificationRepository>(),
        userId: user.uid,
      ),
      child: child,
    );
  }
}
