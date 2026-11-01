import 'package:equatable/equatable.dart';
import 'package:hero/features/auth/auth.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileIdle extends ProfileState {
  const ProfileIdle();
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

final class ProfileRenamed extends ProfileState {
  const ProfileRenamed(this.displayName);

  final String displayName;

  @override
  List<Object?> get props => [displayName];
}

final class ProfileFailed extends ProfileState {
  const ProfileFailed(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}
