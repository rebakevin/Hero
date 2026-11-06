# Hero

A campus incident reporting app for ALU students and staff (Flutter, Android). Students report
problems on campus with photos and vote "me too" on reports they share. Staff review the reports,
set a status and priority with a note, and the reporter is notified.

Firebase Auth and Cloud Firestore hold identity and data. Supabase Storage holds report photos
(Firebase Storage needs the paid plan).

## Links

- [Technical document](https://docs.google.com/document/d/1uZB3Dp4kdKQSVvQJj5ovkp2AhRga8SXa8q2uLNk1wgI/edit?tab=t.0)
- [Hero Design System](https://rebakevin.github.io/Hero/)
- [YouTube Demo Video](https://www.youtube.com/watch?v=t44vSF5tcMU)

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

### Pixel 8 emulator

```bash
~/Library/Android/sdk/emulator/emulator -avd Pixel_8 &
~/Library/Android/sdk/platform-tools/adb wait-for-device shell 'while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done'
flutter run -d emulator-5554
```

### Physical Pixel 8

```bash
flutter run -d "Pixel 8"
```

### Install on physical Pixel 8

Stays on the phone after you unplug the cable.

```bash
flutter build apk --release
~/Library/Android/sdk/platform-tools/adb -d install -r build/app/outputs/flutter-apk/app-release.apk
``` 

### Stop

Press `q` in the `flutter run` terminal, or:

```bash
# Pixel 8 emulator
~/Library/Android/sdk/platform-tools/adb -s emulator-5554 emu kill

# Physical Pixel 8
~/Library/Android/sdk/platform-tools/adb -d shell am force-stop com.alu.hero
```

## Staff accounts

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
