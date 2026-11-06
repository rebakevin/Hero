# Hero — Implementation Plan

Companion to `Hero Specs.md`, `Hero Database Design.md` and `Hero App Prototype.html` (UI
reference).
Five phases, done in order. Each phase is finished in one go and leaves the app runnable.

**Stack change:** Firestore + Firebase Auth stay on Firebase. Photos go to **Supabase Storage**
instead of Firebase Storage (no free tier). `photoPaths` keeps storing object paths; the app turns a
path into a public URL at read time. `storage.rules` is dropped and replaced by Supabase bucket
policies (see Phase 1). Supabase cannot read Firestore, so "only while report is Submitted" is
enforced in the app and Firestore rules only (accepted limitation).

**Assignment requirements and how the plan meets them**

| Requirement                                            | Plan                                                                                                                             |
|--------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| Roles: students submit, staff review and update status | Phase 2 (roles), Phase 3 (students), Phase 4 (staff)                                                                             |
| Modern state management                                | Cubit (`flutter_bloc`), one per feature, repository layer between Cubits and backends                                            |
| Firebase Authentication                                | Phase 2                                                                                                                          |
| Cloud Firestore                                        | Phases 1, 3, 4                                                                                                                   |
| Image storage                                          | Supabase Storage in place of Firebase Storage (Blaze plan needed). Justify in the report, and ideally confirm with the lecturer. |

---

## Phase 1 — Setup and infrastructure

Goal: empty repo to a "hello" app running on a Pixel 8 emulator, wired to Firebase and Supabase.

- [x] **Flutter project**: `flutter create` in the repo root (Android only, package id
  `com.alu.hero`), add the `.gitignore` entries for secrets.
- [x] **Pixel 8 emulator**: create the AVD in Android Studio, confirm `flutter run` boots the
  default app.
- [x] **Firebase project**: create it, register the Android app (add SHA-1), run
  `flutterfire configure`, enable Email/Password auth.
- [x] **Firestore**: create the `(default)` database in Native mode (check region availability
  first, `africa-south1` planned).
- [x] **Rules and indexes**: write `firestore.rules` and `firestore.indexes.json` from the Database
  Design, add `firebase.json` (Firestore only), `firebase deploy --only firestore`.
- [x] **Supabase project**: create a public bucket `report-photos`, JPEG only, 5 MB limit, policy
  allowing anon insert/delete under `reportPhotos/**` and public read.
- [x] **Dependencies**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `supabase_flutter`,
  `flutter_bloc`, `equatable`, `intl`, `image_picker`, `flutter_image_compress`.
- [x] **App skeleton**: folder structure from Specs section 7, `main.dart` initialising Firebase and
  Supabase, `app.dart` with providers, light theme from the prototype, constants (categories,
  buildings, statuses, priorities).
- [x] **Smoke test**: app launches on the emulator and shows a placeholder home; Firebase and
  Supabase connections log success.
- [x] **Staff seed**: create one staff user in the Console with its `users/{uid}` doc (Database
  Design section 10).

**Done when:** `flutter run` works on Pixel 8 and rules/indexes are deployed.

---

## Phase 2 — Authentication and roles

Goal: register, verify, log in, and land on a role-based home.

- [x] **Models and validators**: `AppUser`, email/password/name validators.
- [x] **Repositories**: `AuthRepository`, `UserRepository`.
- [x] **AuthCubit**: states for unauthenticated, unverified, verified student, verified staff;
  session restore on launch.
- [x] **Screens**: Login (with reset password), Register (student domain only), Verify email (
  resend, "I've verified", logout).
- [x] **First verified sign-in**: create `users/{uid}` if missing (W1); block until it exists.
- [x] **AuthGate**: routes by state and role; student cannot reach staff screens.
- [x] **Shell**: bottom nav (Home, My reports or Needs action, Profile) with empty tabs.

**Done when:** a student registers, verifies, and logs in; staff logs in; logout works.

---

## Phase 3 — Reports: create, browse, edit, delete

Goal: the student core loop, end to end, including photos.

- [x] **Models and repositories**: `Report`, `HistoryEntry`, `ReportRepository`,
  `StorageRepository` (Supabase upload, delete, URL).
- [x] **Report form**: category, title, description, building, room, photo picker (camera/gallery,
  max 5, compress to JPEG, under 5 MB), validation, upload progress, no-faces hint.
- [x] **Create (W2)**: upload photos, then one batch for report + `history/initial`; clean up
  uploads on failure.
- [x] **Feed**: live list, newest first, report cards, safety badge, loading/empty/error states.
- [x] **Search and filters**: title prefix, status, category, date range, sort by votes (respect the
  query limits in Database Design section 7).
- [x] **My reports** tab for students.
- [x] **Details screen**: info, photo gallery, reporter, times, owner Edit/Delete only while
  Submitted.
- [x] **Edit (W3) and Delete (W4)**: pre-filled form, confirmation dialog, batch delete of subdocs,
  remove photos from Supabase.

**Done when:** a student can create (with photos), find, edit and delete their own report.

---

## Phase 4 — Staff workflow, voting, notifications, profile

Goal: everything that makes it more than a form.

- [x] **Staff home**: status counts header (aggregate queries), "Needs action" tab.
- [x] **Update status sheet (W5)**: status, priority, required note; one batch with report update,
  history entry and notification.
- [x] **History timeline** on the details screen.
- [x] **Me too voting (W6)**: toggle with live count, blocked on own report.
- [x] **Similar-report hint** in the form while typing the title.
- [x] **Notifications**: bell with unread count, list screen, tap-through, mark read (W7).
- [x] **Profile**: name, email, role, rename for students (W8), logout.
- [x] **Switch account**: up to 5 accounts stay signed in on the device, one tap apart (ADR 0004).

**Done when:** a staff status change appears live on the report, in the timeline, and as a student
notification.

---

## Phase 5 — Polish, tests, submission

Goal: harden, verify, and package.

- [ ] **UI pass** (code reviewed for states and disabled-while-busy, not yet checked by eye against
  the prototype): match the prototype, consistent loading/empty/error states, disable submit buttons
  while busy.
- [x] **Validation pass**: every rule from Specs section 9 on every form (table in Technical
  Documentation, section 13).
- [x] **Unit and widget tests**: validators, `canEdit`, report form (errors on empty, enabled when
  valid).
- [x] **Rules Playground**: run the 23 cases from Database Design section 8. Cases 1 to 21 are
  automated in `scripts/rules-tests/` (`npm test`); 22 and 23 were Storage rules and do not apply.
- [ ] **Manual checklist**: Specs section 9 list, on the Pixel 8 emulator. Written up in
  `docs/Hero Test Checklist.md`; run it and tick the boxes.
- [ ] **Deliverables**: screenshots, 7 to 10 minute demo video, technical report PDF (diagrams,
  rules, Cubit flow, and a short section justifying Supabase over Firebase Storage), push to GitHub.
  The technical documentation is written (`docs/Hero Technical Documentation.md`, plus ADRs in
  `docs/adr/`); export it to PDF with references dated. Screenshots, the video and the push are
  yours.

**Done when:** the submission checklist in Specs section 10 is fully ticked.
