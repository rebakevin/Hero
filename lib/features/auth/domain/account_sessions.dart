import 'device_account.dart';

/// The accounts kept signed in on this device. Each one lives in its own slot,
/// and exactly one slot is active; the app is built against that slot.
abstract interface class AccountSessions {
  String get activeSlot;

  /// Emits the new slot whenever a different one becomes active.
  Stream<String> activeSlotChanges();

  Future<List<DeviceAccount>> accounts();

  /// False when the active slot has no account yet or every slot is taken.
  bool get canAddAccount;

  Future<void> switchTo(String slot);

  /// Activates an empty slot, so the login screen opens for the new account.
  Future<void> addAccount();
}
