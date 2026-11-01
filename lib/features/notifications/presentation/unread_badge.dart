import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/notifications_cubit.dart';
import '../application/notifications_state.dart';

/// Puts the unread count on top of [child] (the bell icon).
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationsCubit, NotificationsState, int>(
      selector: (state) => state.unreadCount,
      builder: (context, count) => Badge(
        isLabelVisible: count > 0,
        label: Text(
          count >= NotificationsCubit.latestLimit ? '$count+' : '$count',
        ),
        child: child,
      ),
    );
  }
}
