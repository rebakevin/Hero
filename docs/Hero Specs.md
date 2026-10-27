# Campus Incident Reporting App — Specification

Oct 26, 2026 · @Kevin Rebakure

## 1. Overview and scope

A Flutter (Android) app where ALU students report campus problems and campus staff triage them
through to resolution, backed by Firebase Auth, Firestore and Storage. It is deliberately minimal:
two roles, one report lifecycle, no admin console.

**Goals**

- Let any student file a report in under a minute, with optional photos.
- Make all reports visible to all students, with "me too" voting to prevent duplicates.
- Give staff one list to review, prioritise, and move reports through statuses with a note each
  time.
- Enforce every rule on the server (Firestore and Storage rules), not just in the UI.

**Decisions locked in**

| Area                | Decision                                                                                |
|---------------------|-----------------------------------------------------------------------------------------|
| Roles               | `student` and `staff` only; no departments                                              |
| Student email       | `@alustudent.com`, email verification required                                          |
| Staff email         | `@alueducation.com`, role set manually in Firestore                                     |
| Categories          | Facilities, Water shortage, Electricity outage, Damaged furniture, Sanitation, Safety   |
| Location            | Fixed list of campus buildings (+ optional room text)                                   |
| Photos              | Multiple per report, 5 MB max each, compressed before upload                            |
| Priority            | Set by staff only                                                                       |
| Statuses            | Submitted, In Progress, Resolved, Rejected; staff can move any direction, note required |
| Student edit/delete | Own reports only, only while status is Submitted                                        |
| Visibility          | All reports visible to all students; reporter name shown (not anonymous)                |
| Extra feature       | "Me too" upvotes on reports                                                             |
| Notifications       | In-app only (no push)                                                                   |
| Staff limits        | Cannot delete reports; can reject                                                       |
| UI                  | Original design, not a copy of the sample mockup; light theme only                      |
| State management    | Cubit (`flutter_bloc`)                                                                  |
| Navigation          | Plain `Navigator`                                                                       |
| Target              | Android emulator + physical Pixel 8                                                     |
| Testing             | Minimal tests; thorough form validation; Firestore security rules                       |

**Out of scope**: push notifications, dark mode, iOS, anonymous reporting, staff departments, admin
screens, comments between students, offline-first sync.

## 2. Roles and access control

Role is decided server-side by a Firestore `users/{uid}` document, never by what the client claims.
Students register themselves; staff accounts are created by you in the Firebase Console and given
`role: "staff"` in Firestore.

**Sign-up and login rules**

- Registration accepts only `@alustudent.com` addresses and always creates `role: "student"`.
- Staff log in with `@alueducation.com` accounts that you pre-create (Auth user + `users/{uid}` doc
  with `role: "staff"`).
- Any other domain is rejected at the form and by a Firestore rule check on the token email.
- Users must verify their email (link sent by Firebase) before the app lets them past the
  verification screen. Rules also require `email_verified == true`.
- Session persists across restarts; logout returns to the login screen.

**Permissions matrix**

| Action                                 | Student                 | Staff                   |
|----------------------------------------|-------------------------|-------------------------|
| Register / log in                      | Yes                     | Log in only             |
| Create report                          | Yes                     | No                      |
| View all reports and details           | Yes                     | Yes                     |
| Search and filter reports              | Yes                     | Yes                     |
| Edit own report                        | Only while Submitted    | No                      |
| Delete own report                      | Only while Submitted    | No                      |
| "Me too" vote (toggle)                 | Yes, on others' reports | No                      |
| Change status (incl. Rejected, reopen) | No                      | Yes, with required note |
| Set priority                           | No                      | Yes                     |
| Delete any report                      | No                      | No                      |
| View own notifications                 | Yes                     | No                      |
| See staff screens                      | No (route blocked)      | Yes                     |

## 3. Features

**3.1 Authentication**

- Email + password registration (student domain only), login, logout, password reset.
- Verification screen with "Resend email" and "I've verified" (reloads the user).
- Auth gate at app root: unauthenticated → login; unverified → verification; verified → home by
  role.

**3.2 Report submission (students)**

- Fields: category, title, description, building (dropdown), room/detail (optional text), photos (
  optional).
- Photos from camera or gallery, multiple allowed (cap at 5 per report to keep it simple), each
  compressed on-device and rejected if still over 5 MB.
- Upload progress and clear errors; the report is written to Firestore only after photo URLs exist.
- Safety category reports show a red badge in lists so they stand out.

**3.3 Browse, search, filter**

- Single feed of all reports, newest first, with live updates.
- Filter by status, category, and date range; search by title text.
- Students also get a "My reports" tab (same list filtered to their uid).
- Cards show title, category, building, status chip, priority chip (once set), "me too" count,
  relative time.

**3.4 Report details**

- Full description, photo gallery, reporter name, building/room, created and updated times.
- Status history timeline: each entry shows status, staff name, note, and time.
- "Me too" toggle (students, not on own report) with live count.
- Edit and Delete buttons for the owner only while status is Submitted.

**3.5 "Me too" voting**

- One vote per student per report; tapping again removes it.
- Reporter is counted automatically and cannot vote on their own report.
- Count is used to help staff prioritise; optionally sortable by most votes.
- Search-before-submit hint: when typing a title, show similar open reports by the same
  category/building so students vote instead of duplicating.

**3.6 Staff review**

- Same feed as students plus a staff-only quick filter for "Needs action" (Submitted and In
  Progress).
- Status update sheet: pick new status, set priority (Low, Medium, High, Urgent), and write a
  required note.
- Any status can move to any other (including back to Submitted or from Rejected), and each change
  appends to the history.
- Staff cannot delete reports or edit their content.
- Dashboard: kept to a simple header of counts by status above the list. No charts.

**3.7 In-app notifications (students)**

- A notification document is created for the reporter when staff change status or priority.
- Bell icon with unread badge; list screen with tap-through to the report; mark as read when opened.
- Staff do not receive notifications.

**3.8 Profile**

- Name, email, role, logout. Students may edit display name.

## 4. User flows

**Student: first run**

1. Open app → login screen → tap Register.
2. Enter name, `@alustudent.com` email, password → submit.
3. Verification screen: open email link → tap "I've verified" → home.

**Student: report an incident**

1. Tap Report → pick category.
2. Enter title; similar open reports appear → vote on one instead, or continue.
3. Add description, pick building, optional room text, optional photos.
4. Submit → progress indicator → success message → report details page (status Submitted).
5. Validation or upload failure: stay on form, field-level or snackbar error, input preserved.

**Student: browse and track**

1. Home feed → search by title, apply status/category/date filters.
2. Open a report → read details and status timeline → "Me too" if relevant.
3. Bell icon → notification ("Your report moved to In Progress") → tap to open it.

**Student: edit or delete own report**

1. My reports → open own report with status Submitted → Edit or Delete.
2. Edit reuses the report form pre-filled; Delete asks for confirmation.
3. Once staff change status, both buttons disappear and the server rejects such writes.

**Staff: triage and update**

1. Log in with `@alueducation.com` → staff home (counts by status + feed).
2. Filter to "Needs action" → open report.
3. Tap Update status → choose status, set priority, enter required note → confirm.
4. Report updates live; reporter receives a notification; timeline shows the entry.

**Status lifecycle**

Submitted, In Progress, Resolved and Rejected are all interchangeable by staff in any direction.
Only Submitted allows the student to edit or delete. Every change is logged with who, when and why.

## 5. Screens

The visual design is yours to invent; this list fixes only what exists and who sees it.

| Screen              | Who     | Purpose                                             |
|---------------------|---------|-----------------------------------------------------|
| Login               | All     | Email + password, link to register and reset        |
| Register            | Student | Name, student email, password, confirm password     |
| Verify email        | All     | Resend link, "I've verified", logout                |
| Home / feed         | All     | Report list, search, filters, status counts (staff) |
| My reports          | Student | Own reports with status filter                      |
| Report form         | Student | Create and edit                                     |
| Report details      | All     | Info, photos, timeline, "me too", owner actions     |
| Update status sheet | Staff   | Status, priority, required note                     |
| Notifications       | Student | List of status/priority changes                     |
| Profile             | All     | Name, email, role, logout                           |

Navigation: bottom bar with Home, My reports (students) or Needs action (staff), and Profile; Report
is a button on Home. Plain `Navigator.push` for detail screens.

## 6. Data model

Firestore is the source of truth; Storage holds only image files. Names use camelCase.

**`users/{uid}`**

| Field       | Type      | Notes                                                  |
|-------------|-----------|--------------------------------------------------------|
| displayName | string    |                                                        |
| email       | string    | Matches Auth email                                     |
| role        | string    | `student` or `staff`; only writable by you via Console |
| createdAt   | timestamp |                                                        |

**`reports/{reportId}`**

| Field                | Type            | Notes                                                         |
|----------------------|-----------------|---------------------------------------------------------------|
| title                | string          | 5 to 80 chars                                                 |
| description          | string          | 10 to 1000 chars                                              |
| category             | string          | facilities, water, electricity, furniture, sanitation, safety |
| building             | string          | From fixed list                                               |
| room                 | string          | Optional, max 40 chars                                        |
| photoUrls            | list of strings | Max 5                                                         |
| status               | string          | submitted, inProgress, resolved, rejected                     |
| priority             | string or null  | low, medium, high, urgent; staff-set                          |
| reporterId           | string          | Owner uid                                                     |
| reporterName         | string          | Copied at creation                                            |
| upvoteCount          | number          | Maintained with voting                                        |
| createdAt, updatedAt | timestamp       |                                                               |

**`reports/{reportId}/upvotes/{uid}`**: `{ createdAt }`. Existence of the document means the user
voted; the parent's `upvoteCount` is changed in the same batched write.

**`reports/{reportId}/history/{entryId}`**:
`{ status, priority, note, staffId, staffName, createdAt }`. Append-only; also written on creation
as the first "Submitted" entry.

**`users/{uid}/notifications/{id}`**: `{ reportId, reportTitle, message, read, createdAt }`. Created
by the staff status update in the same batched write.

**Storage layout**: `reports/{reportId}/{index}.jpg`, readable by any verified user, writable only
by the report's owner while the report is Submitted.

**Indexes needed**: composite on `status` + `createdAt` and on `category` + `createdAt`. Title
search is done client-side on loaded results (prefix match, case-insensitive), which is enough at
campus scale.

## 7. Tech stack and architecture

Flutter with one Cubit per feature and a repository layer between the Cubits and Firebase. Screens
only read Cubit state and call Cubit methods.

| Concern          | Choice                                                   | Why                                                                                                                                             |
|------------------|----------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| Framework        | Flutter + Dart                                           | Assignment requirement                                                                                                                          |
| State management | `flutter_bloc` (Cubit)                                   | Explicit `loading / loaded / empty / error` states match the rubric's feedback requirement, and the Cubit → repository split is easy to explain |
| Backend          | `firebase_auth`, `cloud_firestore`, `firebase_storage`   | Assignment requirement                                                                                                                          |
| Photos           | `image_picker`, `flutter_image_compress`                 | Camera and gallery, compress before upload                                                                                                      |
| Navigation       | Plain `Navigator.push` + an auth gate widget at the root | Simplest option; two roles do not need a router package                                                                                         |
| Models           | Hand-written classes with `fromMap` / `toMap`            | No code generation to debug                                                                                                                     |
| Helpers          | `equatable`, `intl`                                      | Cubit state comparison, date formatting                                                                                                         |

&#91;embedded content: layered architecture · 4 layers, Cubit per feature\]

A Cubit subscribes to a repository's Firestore stream, so every screen watching it updates when a
report or status changes. The report form Cubit also calls `ReportRepository` to save the report
once uploads finish. Repositories are provided at the app root with `RepositoryProvider`; Cubits
with `BlocProvider`.

**Folder structure**

```
lib/
  main.dart                  Firebase init, runApp
  app.dart                   MaterialApp, providers, AuthGate
  core/                      constants (categories, buildings, statuses), theme, validators, utils
  data/
    models/                  AppUser, Report, HistoryEntry, AppNotification
    repositories/            auth, report, user, storage
  features/
    auth/                    auth_cubit, login, register, verify screens
    reports/                 reports_cubit, feed, details, filters, status sheet
    report_form/             report_form_cubit, form screen, photo picker
    notifications/           notification_cubit, list screen
    profile/                 profile screen
  shared/widgets/            status_chip, category_badge, empty_state, error_view, loading_view
test/                        validators_test, permissions_test, report_form_test
```

## 8. Security rules

All permissions in Section 2 are enforced here. The UI hides buttons, but these rules are the real
gate. Starting point (verify in the Rules Playground before the demo):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {

    function signedIn() { return request.auth != null && request.auth.token.email_verified == true; }
    function role() { return get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role; }
    function isStaff() { return signedIn() && role() == 'staff'; }
    function isStudent() { return signedIn() && role() == 'student'; }

    match /users/{uid} {
      allow read: if signedIn() && (request.auth.uid == uid || isStaff());
      allow create: if signedIn() && request.auth.uid == uid
        && request.resource.data.role == 'student'
        && request.auth.token.email.matches('.*@alustudent[.]com');
      allow update: if signedIn() && request.auth.uid == uid
        && request.resource.data.role == resource.data.role;

      match /notifications/{id} {
        allow read, update: if signedIn() && request.auth.uid == uid;
        allow create: if isStaff();
      }
    }

    match /reports/{id} {
      allow read: if signedIn();
      allow create: if isStudent()
        && request.resource.data.reporterId == request.auth.uid
        && request.resource.data.status == 'submitted'
        && request.resource.data.upvoteCount == 0;
      allow update: if
        (isStudent() && resource.data.reporterId == request.auth.uid
          && resource.data.status == 'submitted'
          && request.resource.data.status == 'submitted')
        || isStaff()
        || (isStudent() && request.resource.data.diff(resource.data)
              .affectedKeys().hasOnly(['upvoteCount']));
      allow delete: if isStudent() && resource.data.reporterId == request.auth.uid
        && resource.data.status == 'submitted';

      match /upvotes/{uid} {
        allow read: if signedIn();
        allow create, delete: if isStudent() && request.auth.uid == uid;
      }
      match /history/{entry} {
        allow read: if signedIn();
        allow create: if isStaff() || isStudent();
        allow update, delete: if false;
      }
    }
  }
}
```

**Known gaps to tighten if time allows**: restrict staff updates to only status, priority and
updatedAt; restrict the vote counter to changes of exactly +1 or -1 and tie it to the vote document;
limit student history creation to the initial "submitted" entry. Mention these as limitations in the
report if left as is.

**Storage rules**: allow read for verified users; allow write on `reports/{reportId}/**` only if
`request.resource.size < 5 * 1024 * 1024`, content type starts with `image/`, and the caller owns
the report (looked up with `firestore.get`) while it is still Submitted.

**Other protections**: no client-supplied role is ever trusted; staff accounts exist only if you
create them; there is no public sign-up path to `staff`.

## 9. Validation, errors and testing

**Form validation (all required to pass before submit)**

| Field               | Rule                                                                                      |
|---------------------|-------------------------------------------------------------------------------------------|
| Email (register)    | Required, valid format, ends with `@alustudent.com`                                       |
| Email (staff login) | Valid format; accepts `@alueducation.com` or `@alustudent.com`, role decided by Firestore |
| Password            | Required, min 8 chars, at least one letter and one number; confirm must match             |
| Display name        | Required, 2 to 50 chars                                                                   |
| Title               | Required, 5 to 80 chars, trimmed                                                          |
| Description         | Required, 10 to 1000 chars                                                                |
| Category, building  | Required selection                                                                        |
| Room                | Optional, max 40 chars                                                                    |
| Photos              | Max 5; images only; each under 5 MB after compression                                     |
| Status note (staff) | Required, 3 to 300 chars                                                                  |

**Loading, empty and error states**: every Cubit exposes `loading`, `loaded`, `empty` and `error`
states; screens render a spinner, an empty-state message with a call to action, or an error with
Retry. Submit buttons disable while a request is running to prevent double submits.

**Testing (kept minimal on purpose)**

- Unit tests: validators (email domain, password, title, description) and the status/permission
  helper (`canEdit(report, user)`).
- Widget test: report form shows errors on empty submit and enables Submit when valid.
- Manual test checklist (go in the report): register with wrong domain, unverified login, create
  with and without photos, oversize photo, edit and delete while Submitted, edit blocked after
  status change, student blocked from staff screen, staff status change with and without note,
  me-too toggle, notification appears, rules tested in the Firebase Rules Playground.

**Privacy and misuse notes for the report**: reporter name is visible by design; staff can reject
spam or duplicates; only verified ALU emails can post; photos should not include people's faces (add
a hint on the form).

## 10. Build plan, deliverables and open assumptions

**Build order** (each step is demo-able on its own)

1. Firebase project, Android app registration, FlutterFire setup, Auth + Firestore + Storage
   enabled.
2. Auth: register, login, verification gate, role loading, logout.
3. Report model, repository, and create flow (no photos), then photo upload with compression.
4. Feed, details, search and filters.
5. Student edit and delete rules in UI and in security rules.
6. Staff status update with note, priority, and history timeline.
7. "Me too" voting and similar-report hint.
8. In-app notifications.
9. Validation pass, loading/error/empty states, UI polish.
10. Security rules test in Playground, minimal tests, manual checklist.
11. Screenshots, report, demo recording.

**Rubric coverage**

| Rubric area               | Where this spec covers it                                       |
|---------------------------|-----------------------------------------------------------------|
| Authentication (6)        | 2, 3.1: domain restriction, email verification, session gate    |
| Firestore CRUD (6)        | 6: create, read, update, student delete, history                |
| State management (8)      | 7: Cubit per feature, repository layer                          |
| Features (7)              | 3: submit, photos, filters, details, status tracking            |
| UI/UX (6)                 | 5, 9: loading/error states, original design                     |
| Code quality (5)          | 7: feature folders, reusable widgets                            |
| Product thinking (5)      | 3.5, 9: voting, duplicate hint, priority, reject, privacy notes |
| Technical explanation (7) | Prepare to explain Cubit flow, rules, and data model            |
| Report (5)                | Diagrams from 7 and 6, rules from 8, checklist from 9           |

**Submission checklist**

- [ ] GitHub repository link (public or accessible to grader)
- [ ] 7 to 10 minute demo video: auth, submit report, browse and filter, staff status update,
  Firebase Console records
- [ ] Technical report as PDF with APA or IEEE references (not a Google Doc link)
- [ ] Runs on Android emulator or Pixel 8
- [ ] File name `StudentName_Assignment2` on Canvas

**Assumptions I made where you were not explicit** (change any you disagree with)

- Photos can come from both camera and gallery, capped at 5 per report.
- Room is an optional free-text field beside the building dropdown.
- Priority levels are Low, Medium, High, Urgent and are unset until staff set one.
- Search and filters cover title text, status, category and date range; nothing more.
- "Dashboard" means status counts at the top of the staff feed, not a separate screen.
- Staff can also change priority without changing status.
- Staff accounts use `@alueducation.com` and are created by you in the Console.
- The buildings list is a Dart constant; you still need to fill in the real building names.

**Still to decide**

- Real list of campus buildings.
- Whether staff may also use the sign-in screen for password reset.
