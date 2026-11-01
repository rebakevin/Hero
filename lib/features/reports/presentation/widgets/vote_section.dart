import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../../application/vote_cubit.dart';
import '../../application/vote_state.dart';
import '../../domain/report.dart';
import '../../domain/vote_repository.dart';
import '../report_failure_message.dart';

/// The "me too" toggle. Shown only to students who did not file the report.
class VoteSection extends StatelessWidget {
  const VoteSection({super.key, required this.report, required this.user});

  final Report report;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    if (!report.canBeVotedBy(user)) return const SizedBox.shrink();
    return BlocProvider(
      create: (context) => VoteCubit(
        repository: context.read<VoteRepository>(),
        voter: user,
        reportId: report.id,
      ),
      child: _VoteButton(votes: report.upvoteCount),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.votes});

  final int votes;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoteCubit, VoteState>(
      listenWhen: (previous, current) =>
          current.status == VoteStatus.failed &&
          previous.status != VoteStatus.failed,
      listener: (context, state) {
        final failure = state.failure;
        if (failure == null) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      builder: (context, state) {
        final busy =
            state.status == VoteStatus.loading ||
            state.status == VoteStatus.saving;
        final icon = Icon(
          state.hasVoted
              ? Icons.thumb_up_alt_rounded
              : Icons.thumb_up_alt_outlined,
        );
        final label = Text(
          state.hasVoted ? 'You said me too · $votes' : 'Me too · $votes',
        );
        final onPressed = busy ? null : context.read<VoteCubit>().toggle;
        return state.hasVoted
            ? FilledButton.icon(onPressed: onPressed, icon: icon, label: label)
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: icon,
                label: label,
              );
      },
    );
  }
}
