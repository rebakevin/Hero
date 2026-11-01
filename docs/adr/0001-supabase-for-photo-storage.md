# ADR 0001 — Supabase Storage for photos instead of Firebase Storage

Nov 1, 2026 · Status: accepted

## Context

The assignment names Firebase Storage for images. Creating a Firebase Storage bucket now requires
the paid Blaze plan, and this project has no budget. Firebase Auth and Cloud Firestore are still
available on the free plan.

## Decision

Keep Firebase Auth and Firestore, and store report photos in a public Supabase Storage bucket
(`report-photos`, JPEG only, 5 MB limit).

- Reports store `photoPaths` (`reportPhotos/{uid}/{reportId}/{randomId}.jpg`), never URLs. The app
  turns a path into a public URL at read time (`PhotoUrlResolver`).
- Only `SupabasePhotoStorage` imports `supabase_flutter`. Everything else sees the `PhotoStorage`
  contract.
- The app uses the Supabase publishable (anon) key with anon insert, delete and select policies
  limited to the `reportPhotos/` prefix. `storage.rules` was dropped.

## Consequences

- Supabase cannot see Firebase Auth or Firestore, so "only the owner, only while Submitted" for
  photos is enforced in the app (in the repository, before upload and delete) and not by the
  storage layer. A modified client could write files under the prefix but cannot attach them to
  anyone else's report, because `photoPaths` is protected by the Firestore rules.
- The two systems cannot share a transaction. Create uploads first and cleans up if the batch is
  refused; delete removes the report first and the files afterwards.
- The report must justify the substitution, and ideally the lecturer should confirm it.
- Moving back to Firebase Storage later means a new `PhotoStorage` implementation and a path
  migration; nothing else changes.
