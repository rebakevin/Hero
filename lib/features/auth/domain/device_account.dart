import 'package:equatable/equatable.dart';

/// An account signed in on this device, ready to switch to without a password.
class DeviceAccount extends Equatable {
  const DeviceAccount({
    required this.slot,
    required this.email,
    required this.isActive,
    this.displayName,
  });

  /// How many accounts can stay signed in on one device.
  static const maxPerDevice = 5;

  final String slot;
  final String email;
  final bool isActive;
  final String? displayName;

  @override
  List<Object?> get props => [slot, email, isActive, displayName];
}
