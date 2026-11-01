# Hero

A campus incident reporting app for ALU students and staff (Flutter, Android). Students report
problems on campus with photos and vote "me too" on reports they share. Staff review the reports,
set a status and priority with a note, and the reporter is notified.

Firebase Auth and Cloud Firestore hold identity and data. Supabase Storage holds report photos
(Firebase Storage needs the paid plan; see `docs/adr/0001-supabase-for-photo-storage.md`).

## Documentation

| Document                                 | What it covers                                              |
|------------------------------------------|-------------------------------------------------------------|
| `docs/Hero Specs.md`                     | Features, flows, screens, validation rules                  |
| `docs/Hero Database Design.md`           | Collections, security rules, write batches, indexes         |
| `docs/Hero Technical Documentation.md`   | How the app is built: architecture, state, data flow, security, testing |
| `docs/Hero Test Checklist.md`            | Manual test checklist and the security rules cases          |
| `docs/Hero Todo.md`                      | The phased plan and its progress                            |
| `docs/adr/`                              | Architecture decision records                               |

## Set up

You need the Flutter SDK, the Android SDK with an AVD named `Pixel_8`, Node.js, and the Firebase
CLI logged in to the `hero-e61aa` project.

```bash
cp .env.example .env        # fill in SUPABASE_URL, SUPABASE_KEY, SUPABASE_BUCKET
flutter pub get
```

Supabase needs a public bucket `report-photos` (JPEG only, 5 MB) with anon insert, delete and
select policies limited to the `reportPhotos/` prefix.

## Run

```bash
~/Library/Android/sdk/emulator/emulator -avd Pixel_8 &
flutter run -d emulator-5554
```

Staff accounts are not created in the app. Create the user in the Firebase Console, then:

```bash
node scripts/seed-staff.js staff@alueducation.com "Display Name"
```

## Test

```bash
flutter analyze
flutter test                                   # unit, Cubit, widget and architecture tests
cd scripts/rules-tests && npm install && npm test   # Firestore security rules on the emulator
```

## Deploy rules and indexes

```bash
firebase deploy --only firestore --project hero-e61aa
```

## Structure

```
lib/features/<feature>/{domain,application,data,presentation}   one barrel file per feature
lib/core, lib/shared                                            theme, env, generic widgets
test/                                                           mirrors lib/
scripts/                                                        staff seeding, rules tests
```

See the Technical Documentation, section 4, for the full layout and the import rules.
