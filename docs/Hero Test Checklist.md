# Hero — Manual Test Checklist

Nov 1, 2026 · Companion to `docs/Hero Specs.md` (section 9 lists the scenarios) and
`docs/Hero Technical Documentation.md` (section 15 covers the automated tests).

The automated tests cover logic, state and the security rules. This checklist covers what only a
person on the device can see: real Firebase, real Supabase, the camera, and how it looks. Run it on
the Pixel 8 emulator before recording the demo, tick each box, and note anything that fails in the
last column or in section 6. Results go in the report.

**Before you start**

| Item          | Detail                                                                              |
|---------------|-------------------------------------------------------------------------------------|
| App           | `flutter run -d emulator-5554` with a filled `.env`                                 |
| Student A     | A real `@alustudent.com` mailbox you can open (registers during the run)            |
| Student B     | A second `@alustudent.com` mailbox (votes, and checks that A's reports are not editable) |
| Staff         | `kevin@alueducation.com`, created in the Console and seeded with `scripts/seed-staff.js` |
| Rules         | Deployed: `firebase deploy --only firestore --project hero-e61aa`                   |
| Photos        | A few JPEG and PNG files in the emulator gallery, one very large image (over 5 MB)  |
| Clean state   | Optional: clear app data so the first run starts at the login screen                |

---

## 1. Authentication

| #   | Scenario                                              | Expected                                                                 | Pass |
|-----|-------------------------------------------------------|--------------------------------------------------------------------------|------|
| 1.1 | Register with `name@gmail.com`                        | Field error asking for an `@alustudent.com` email; nothing is created    | [ ]  |
| 1.2 | Register with weak passwords ("short", "allletters")  | Field errors for length and for the missing number; confirm must match   | [ ]  |
| 1.3 | Register Student A with a valid email                 | Verification screen appears; a verification email arrives                | [ ]  |
| 1.4 | Tap "I've verified" before opening the link           | Message that the email is not verified yet; stays on the screen          | [ ]  |
| 1.5 | Open the link, tap "I've verified"                    | Lands on the student Home                                                | [ ]  |
| 1.6 | Resend the verification email                         | Confirmation message; a new email arrives                                | [ ]  |
| 1.7 | Log out, log in with a wrong password                 | Generic "email or password is incorrect"; does not say which one         | [ ]  |
| 1.8 | Log in with an unknown email                          | The same generic message                                                 | [ ]  |
| 1.9 | Reset password                                        | Confirmation shown for any email; reset email arrives for a real one     | [ ]  |
| 1.10| Close and reopen the app while logged in              | Goes straight to Home (session restored)                                 | [ ]  |
| 1.11| Log in as an unverified account                       | Held on the verification screen, never reaches Home                      | [ ]  |
| 1.12| Log in as staff                                       | Staff shell: Needs action, All reports, Profile                          | [ ]  |
| 1.13| Student shell                                         | Home, My reports, Alerts, Profile only; no staff screens reachable       | [ ]  |

## 2. Student: create, find, edit, delete

| #   | Scenario                                              | Expected                                                                 | Pass |
|-----|-------------------------------------------------------|--------------------------------------------------------------------------|------|
| 2.1 | Report, then Submit with every field empty            | Errors on category, title, description, building; nothing is sent        | [ ]  |
| 2.2 | Title of 4 characters, description of 9               | Length errors on both                                                    | [ ]  |
| 2.3 | Create a report without photos                        | Snackbar "Report submitted", details screen opens, status Submitted      | [ ]  |
| 2.4 | Create a report with 3 photos (camera and gallery)    | Progress "Uploading photos i of 3"; photos show on the details screen    | [ ]  |
| 2.5 | Try to add a 6th photo                                | Add tile disappears at 5; picker never asks for more                     | [ ]  |
| 2.6 | Pick the over-5 MB image                              | Compressed to fit, or a clear "still over 5 MB" message; form unchanged  | [ ]  |
| 2.7 | Pick a PNG                                            | Accepted and stored as JPEG                                              | [ ]  |
| 2.8 | Create a Safety report                                | Red Safety badge in the list and on the details screen                   | [ ]  |
| 2.9 | Turn on airplane mode, submit                         | After the timeout: "No connection"; text and photos still in the form    | [ ]  |
| 2.10| Turn the network back on and submit again             | Exactly one report is created                                            | [ ]  |
| 2.11| Type a title similar to an open report (same category and building) | "Already reported?" card lists it; tapping opens it        | [ ]  |
| 2.12| Search the title prefix, in any letter case           | Matching reports only                                                    | [ ]  |
| 2.13| Filter by status, by category, by date range          | List matches; the filter button shows the number of active filters       | [ ]  |
| 2.14| Sort by most "me too"; also combine with a date range | Ordered by votes, date range still respected                             | [ ]  |
| 2.15| Search plus filters with no match                     | "No matching reports" with a hint to clear filters                       | [ ]  |
| 2.16| My reports tab                                        | Only A's reports                                                         | [ ]  |
| 2.17| Edit own Submitted report (change text, remove a photo, add a photo) | Details update live; removed photo disappears               | [ ]  |
| 2.18| Delete own Submitted report, confirm                  | Returns to the list with "Report deleted"; it is gone from every list    | [ ]  |
| 2.19| Cancel the delete dialog                              | Nothing happens                                                          | [ ]  |
| 2.20| Check the Firebase Console after a delete             | Report, its history, votes and notifications are gone                    | [ ]  |
| 2.21| Check the Supabase bucket after a delete or a photo edit | The removed files are gone                                            | [ ]  |

## 3. Voting

| #   | Scenario                                              | Expected                                                                 | Pass |
|-----|-------------------------------------------------------|--------------------------------------------------------------------------|------|
| 3.1 | Student B opens A's report                            | "Me too" button with the count                                           | [ ]  |
| 3.2 | Tap it                                                | Button turns to "You said me too", count +1, live on A's device          | [ ]  |
| 3.3 | Tap again                                             | Vote removed, count back                                                 | [ ]  |
| 3.4 | Student A opens their own report                      | No "Me too" button                                                       | [ ]  |
| 3.5 | Staff opens a report                                  | No "Me too" button                                                       | [ ]  |

## 4. Staff workflow and notifications

| #   | Scenario                                              | Expected                                                                 | Pass |
|-----|-------------------------------------------------------|--------------------------------------------------------------------------|------|
| 4.1 | Staff Needs action tab                                | Only Submitted and In Progress reports; counts header above the list     | [ ]  |
| 4.2 | Status counts                                         | Match the Console; refresh after an update                               | [ ]  |
| 4.3 | Open a report, Update status, leave the note empty    | Note error; nothing is sent                                              | [ ]  |
| 4.4 | Keep status and priority unchanged, write a note      | Rejected with a message; nothing is sent                                 | [ ]  |
| 4.5 | Set In Progress and High priority with a note         | Sheet closes; status, priority chips and updated time change live        | [ ]  |
| 4.6 | Look at the history on the details screen             | New entry: who, status and priority change, the note, the time           | [ ]  |
| 4.7 | Move a report back to Submitted, and from Rejected    | Allowed in any direction; each change adds a history entry               | [ ]  |
| 4.8 | Change only the priority                              | One history entry; the student gets a priority notification              | [ ]  |
| 4.9 | On the student device: Alerts tab                     | Badge with the unread count; notification text matches the change        | [ ]  |
| 4.10| Tap the notification                                  | Opens the report; the notification is marked read and the badge drops    | [ ]  |
| 4.11| Student edits or deletes after the status changed     | Edit and Delete buttons are gone                                         | [ ]  |
| 4.12| Staff on an owner's report                            | No Edit or Delete buttons; staff never receive notifications             | [ ]  |
| 4.13| Two staff update the same report at once (two emulators) | The slower one sees "This report changed" and can retry                | [ ]  |

## 5. Profile and general behavior

| #   | Scenario                                              | Expected                                                                 | Pass |
|-----|-------------------------------------------------------|--------------------------------------------------------------------------|------|
| 5.1 | Student changes display name                          | "Name updated"; profile shows it; old reports keep the old name          | [ ]  |
| 5.2 | Name of 1 character                                   | Field error                                                              | [ ]  |
| 5.3 | Staff profile                                         | No "Change name" button                                                  | [ ]  |
| 5.4 | Log out from Profile                                  | Back to Login; no private screen left on top                             | [ ]  |
| 5.5 | Rotate / large font size / smaller phone              | No overflow errors; forms scroll                                         | [ ]  |
| 5.6 | Every list and details screen                         | Spinner while loading, empty message, error with Retry (airplane mode)   | [ ]  |
| 5.7 | Profile > Switch account > Add, log in as a second user | Second user's home; first account listed under Switch account          | [ ]  |
| 5.8 | Tap the other account                                 | Opens with no password; shows only that account's reports and role       | [ ]  |
| 5.9 | Restart the app after switching                       | Reopens on the last account; both stay listed                            | [ ]  |
| 5.10| Log out of one account                                | Login screen; only the other account listed under "Use a signed-in account" | [ ]  |
| 5.11| Add an account that is already listed                 | Listed once only                                                         | [ ]  |
| 5.7 | Submit buttons while a request runs                   | Show a spinner and cannot be tapped twice                                | [ ]  |
| 5.8 | Photos that fail to load (turn off network after opening a list) | A grey placeholder; the rest of the card is intact            | [ ]  |

## 6. Security rules

The Firestore rules are tested by `scripts/rules-tests/` (`npm test`), which automates cases 1 to
21 below. Run it before the demo and keep the output. Cases 22 and 23 were Firebase Storage rules;
photos now live in Supabase, so they do not apply (Technical Documentation, section 10.4).

| #  | Case                                                                  | Expected | Automated | Console check |
|----|-----------------------------------------------------------------------|----------|-----------|---------------|
| 1  | Unverified user reads `reports`                                       | Deny     | Pass      | [ ]           |
| 2  | `@gmail.com` verified user reads `reports`                            | Deny     | Pass      | [ ]           |
| 3  | Student creates `users/{uid}` with `role: "staff"`                    | Deny     | Pass      | [ ]           |
| 4  | Student creates report with `upvoteCount: 3` / `status: "inProgress"` | Deny     | Pass      | [ ]           |
| 5  | Student creates report without the `history/initial` doc              | Deny     | Pass      | [ ]           |
| 6  | Student edits own report while `submitted`                            | Allow    | Pass      | [ ]           |
| 7  | Student edits own report after status is `inProgress`                 | Deny     | Pass      | [ ]           |
| 8  | Student edits another student's report                                | Deny     | Pass      | [ ]           |
| 9  | Student changes `status` or `priority`                                | Deny     | Pass      | [ ]           |
| 10 | Student votes on own report                                           | Deny     | Pass      | [ ]           |
| 11 | Student votes without the vote doc / changes the count by 2           | Deny     | Pass      | [ ]           |
| 12 | Student votes twice                                                   | Deny     | Pass      | [ ]           |
| 13 | Staff updates status with matching history and notification           | Allow    | Pass      | [ ]           |
| 14 | Staff updates status without a note / without history                 | Deny     | Pass      | [ ]           |
| 15 | Staff updates `title` or deletes a report                             | Deny     | Pass      | [ ]           |
| 16 | Staff creates a notification not tied to a report change              | Deny     | Pass      | [ ]           |
| 17 | Student marks own notification read                                   | Allow    | Pass      | [ ]           |
| 18 | Student reads another user's notification                             | Deny     | Pass      | [ ]           |
| 19 | Student deletes own `submitted` report with its subdocs (one batch)   | Allow    | Pass      | [ ]           |
| 20 | Same, after status is `resolved`                                      | Deny     | Pass      | [ ]           |
| 21 | Student updates or deletes a history entry alone                      | Deny     | Pass      | [ ]           |
| 22 | Upload 6 MB / `image/png` / to another user's path                    | n/a      | Skipped   | n/a           |
| 23 | Upload to own path for a report that is no longer `submitted`         | n/a      | Skipped   | n/a           |

The "Automated" column is the result of the last run of the rules suite on the Firestore emulator.
The "Console check" column is optional: repeat any case in the Rules Playground if the grader
expects a screenshot.

## 7. Issues found

| # | Where | What happened | Fixed |
|---|-------|---------------|-------|
|   |       |               | [ ]   |
