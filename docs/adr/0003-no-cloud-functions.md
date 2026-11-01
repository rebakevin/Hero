# ADR 0003 — No Cloud Functions; batched writes validated by the security rules

Nov 1, 2026 · Status: accepted

## Context

A report needs a history entry, vote counter and notification kept consistent with it. The usual
tool is a Cloud Function, but deploying functions needs the paid Blaze plan, and a function would
be one more thing to run and explain.

## Decision

The client writes every related document in **one Firestore batch** (W2 to W6), and the security
rules validate the whole batch using `getAfter()` and `existsAfter()`:

- a new report needs `history/initial` in the same batch;
- a staff status change needs a history entry whose `from*` and `to*` match the report before and
  after, and a typed notification for the reporter;
- a vote changes `upvoteCount` by exactly ±1 together with the vote document.

Documents have exact key sets, and `createdAt` / `updatedAt` must equal `request.time`.

## Consequences

- No server code to deploy, and the rules are the single place that defines what is allowed.
- A batch may not be split. The repository owns each batch, and Cubits call a method named for the
  use case.
- Some invariants cannot be expressed. The rules cannot require the notification on a staff update
  (the report holds no pointer to it), cannot loop over `photoPaths`, and a single delete batch is
  capped at 500 operations. These are listed in the Technical Documentation, section 18.
- Races are resolved by the batch preconditions: the losing client gets `permission-denied`, which
  the app shows as "This report changed" and does not treat as a crash.
- The rules are tested on the Firestore emulator (`scripts/rules-tests/`).
