# ADR 0004 — Named Firebase apps for switching accounts

Nov 6, 2026 · Status: accepted

## Context

People share devices and test with several accounts, and logging out and back in each time is slow.
A `FirebaseAuth` instance holds one signed-in user. The client SDK cannot sign in again from a saved
refresh token, and custom tokens would need a backend, which this project does not have (ADR 0003).
Saving passwords on the device to replay them is not acceptable.

## Decision

Give each account its own named `FirebaseApp`, up to `DeviceAccount.maxPerDevice` (5) slots. The
default app stays the first slot, so existing sessions survive the upgrade.

- Each app persists its own Auth session and Firestore cache. No password or token is handled by
  our code.
- `FirebaseAccountSessions` owns the slots and saves the active slot name in `shared_preferences`.
- `HeroRoot` builds `HeroApp` against the active slot under a `ValueKey`. A switch discards every
  Cubit, listener and screen of the previous account, so nothing of theirs stays on show.
- Logging out signs out only the active slot, which removes that account from the list.
- Logging in to an account another slot already holds signs that other slot out.

## Consequences

- Anyone holding an unlocked phone can open any listed account without a password. This matches the
  existing behaviour of staying signed in, but now covers several accounts. Logging out is how to
  remove an account from a shared device.
- Firestore rules are unchanged. Each instance sends its own user's token, so permissions still
  apply per account.
- Only the active account listens for data, so other accounts show no unread count and the app
  sends no background notifications for them.
- The account list reads names from each slot's Firestore cache, because a rename updates only
  `users/{uid}`. An account that has not loaded its profile yet shows its Auth name or email.
- Startup initialises five Firebase apps instead of one.
