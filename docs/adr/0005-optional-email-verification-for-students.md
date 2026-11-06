# ADR 0005 — Optional email verification for students

Nov 6, 2026 · Status: accepted

## Context

Testing needs many student accounts. Every account had to verify through a link sent to its inbox,
so dummy addresses could not get past the verification screen, and the rules rejected them too.

## Decision

Students may use the app without verifying. Verification stays available.

- Registration still sends the verification email. Unverified students go straight to Home, and
  Profile shows a "Verify email" button until they verify.
- `firestore.rules` no longer requires `email_verified` for `@alustudent.com` users. A student still
  needs that domain and `users/{uid}.role == 'student'`.
- Staff must still verify, in the app and in the rules. An unverified `@alueducation.com` account is
  held on the verification screen.
- `FirebaseAuthRepository` holds back the session of a new account until its display name is saved.
  The verification screen used to delay W1 long enough to hide this race.

## Consequences

- **The email address no longer proves identity.** Anyone can register any `@alustudent.com` address
  they do not own and post under it. A real student whose address was taken cannot register it until
  the account is deleted in the Firebase Console.
- This relaxes the "verified ALU emails" requirement in the Specs and the assignment's
  authentication criteria, so the demo and report must either explain it or revert it.
- To restore the requirement, revert this change and redeploy the rules. Accounts created meanwhile
  are then held on the verification screen, and dummy ones should be deleted in the Console.
