import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/report_failure.dart';
import '../domain/vote_repository.dart';
import 'vote_state.dart';

/// The signed-in student's "me too" vote on one report, with live state.
class VoteCubit extends Cubit<VoteState> {
  VoteCubit({
    required this._repository,
    required this._voter,
    required this._reportId,
  }) : super(const VoteState()) {
    _subscription = _repository
        .watchHasVoted(reportId: _reportId, voter: _voter)
        .listen(_onVoteChanged, onError: _onError);
  }

  final VoteRepository _repository;
  final AppUser _voter;
  final String _reportId;
  late final StreamSubscription<bool> _subscription;

  /// Adds the vote, or removes it when already cast.
  Future<void> toggle() async {
    if (!state.canToggle) return;
    final removing = state.hasVoted;
    emit(state.copyWith(status: VoteStatus.saving, failure: () => null));
    try {
      if (removing) {
        await _repository.removeVote(reportId: _reportId, voter: _voter);
      } else {
        await _repository.vote(reportId: _reportId, voter: _voter);
      }
      if (!isClosed && state.status == VoteStatus.saving) {
        emit(state.copyWith(status: VoteStatus.idle));
      }
    } on ReportException catch (error) {
      if (!isClosed) _fail(error.failure);
    } catch (error, stackTrace) {
      log(
        'Toggling vote failed',
        name: 'VoteCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed) _fail(ReportFailure.unknown);
    }
  }

  void _onVoteChanged(bool hasVoted) {
    // Stay in "saving" until the write settles; only the flag follows the server.
    final status = state.status == VoteStatus.loading
        ? VoteStatus.idle
        : state.status;
    emit(state.copyWith(status: status, hasVoted: hasVoted));
  }

  void _onError(Object error, StackTrace stackTrace) {
    log(
      'Watching vote failed',
      name: 'VoteCubit',
      error: error,
      stackTrace: stackTrace,
    );
    _fail(error is ReportException ? error.failure : ReportFailure.unknown);
  }

  void _fail(ReportFailure failure) =>
      emit(state.copyWith(status: VoteStatus.failed, failure: () => failure));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
