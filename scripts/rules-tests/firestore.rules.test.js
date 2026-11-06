// Automates the 23 Rules Playground cases, plus the allowed paths they depend on. Run with `npm test` (starts the Firestore emulator).
// Cases 22 and 23 cover Firebase Storage; photos moved to Supabase, so they are skipped here.
const { readFileSync } = require("node:fs");
const path = require("node:path");
const { describe, it, before, after, beforeEach } = require("node:test");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const {
  doc,
  setDoc,
  getDoc,
  updateDoc,
  deleteDoc,
  writeBatch,
  serverTimestamp,
  increment,
  Timestamp,
  setLogLevel,
} = require("firebase/firestore");

setLogLevel("silent");

const STUDENT = { uid: "student1", email: "amina@alustudent.com", name: "Amina Hassan" };
const OTHER = { uid: "student2", email: "brian@alustudent.com", name: "Brian Otieno" };
const STAFF = { uid: "staff1", email: "kevin@alueducation.com", name: "Kevin Staff" };

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "hero-rules-test",
    firestore: {
      rules: readFileSync(path.join(__dirname, "../../firestore.rules"), "utf8"),
    },
  });
});

after(() => env.cleanup());

const as = (user, { verified = true, email = user.email } = {}) =>
  env.authenticatedContext(user.uid, { email, email_verified: verified }).firestore();

const now = () => Timestamp.now();

const userDoc = (user, role = "student") => ({
  displayName: user.name,
  email: user.email,
  role,
  createdAt: now(),
});

const reportDoc = (overrides = {}) => ({
  title: "Broken tap in hostel",
  titleLower: "broken tap in hostel",
  description: "The tap on the second floor leaks all day.",
  category: "water",
  building: "hostels",
  room: "",
  photoPaths: [],
  status: "submitted",
  priority: null,
  lastHistoryId: "initial",
  reporterId: STUDENT.uid,
  reporterName: STUDENT.name,
  upvoteCount: 0,
  createdAt: now(),
  updatedAt: now(),
  ...overrides,
});

const initialHistory = (overrides = {}) => ({
  actorId: STUDENT.uid,
  actorName: STUDENT.name,
  actorRole: "student",
  fromStatus: null,
  toStatus: "submitted",
  fromPriority: null,
  toPriority: null,
  note: "Report submitted",
  createdAt: serverTimestamp(),
  ...overrides,
});

// A new report as the app writes it: report plus history/initial in one batch.
const newReportFields = (overrides = {}) => ({
  ...reportDoc({ createdAt: serverTimestamp(), updatedAt: serverTimestamp() }),
  ...overrides,
});

async function seed(callback) {
  await env.withSecurityRulesDisabled(async (context) => callback(context.firestore()));
}

async function seedReport(overrides = {}) {
  await seed(async (db) => {
    await setDoc(doc(db, "reports/r1"), reportDoc(overrides));
    await setDoc(doc(db, "reports/r1/history/initial"), { ...initialHistory(), createdAt: now() });
  });
}

// What the app writes for a staff update (W5).
function staffUpdateBatch(db, { note = "Plumber booked", withHistory = true, withNotification = true } = {}) {
  const batch = writeBatch(db);
  batch.update(doc(db, "reports/r1"), {
    status: "inProgress",
    priority: "high",
    lastHistoryId: "h1",
    updatedAt: serverTimestamp(),
  });
  if (withHistory) {
    batch.set(doc(db, "reports/r1/history/h1"), {
      actorId: STAFF.uid,
      actorName: STAFF.name,
      actorRole: "staff",
      fromStatus: "submitted",
      toStatus: "inProgress",
      fromPriority: null,
      toPriority: "high",
      note,
      createdAt: serverTimestamp(),
    });
  }
  if (withNotification) {
    batch.set(doc(db, "users/student1/notifications/n1"), notificationFields());
  }
  return batch;
}

const notificationFields = (overrides = {}) => ({
  reportId: "r1",
  reportTitle: "Broken tap in hostel",
  type: "both",
  status: "inProgress",
  priority: "high",
  message: "Your report moved to In Progress",
  read: false,
  createdAt: serverTimestamp(),
  ...overrides,
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed(async (db) => {
    await setDoc(doc(db, `users/${STUDENT.uid}`), userDoc(STUDENT));
    await setDoc(doc(db, `users/${OTHER.uid}`), userDoc(OTHER));
    await setDoc(doc(db, `users/${STAFF.uid}`), userDoc(STAFF, "staff"));
  });
});

describe("1-2. identity", () => {
  it("1. unverified staff reads reports -> deny", async () => {
    await seedReport();
    await assertFails(getDoc(doc(as(STAFF, { verified: false }), "reports/r1")));
  });

  it("unverified student reads reports -> allow", async () => {
    await seedReport();
    await assertSucceeds(getDoc(doc(as(STUDENT, { verified: false }), "reports/r1")));
  });

  it("unverified @gmail.com user reads reports -> deny", async () => {
    await seedReport();
    const gmail = { uid: "gmail1", email: "someone@gmail.com" };
    await assertFails(getDoc(doc(as(gmail, { verified: false }), "reports/r1")));
  });

  it("unverified staff updates a report -> deny", async () => {
    await seedReport();
    await assertFails(
      updateDoc(doc(as(STAFF, { verified: false }), "reports/r1"), { status: "resolved" }),
    );
  });

  it("2. verified @gmail.com user reads reports -> deny", async () => {
    await seedReport();
    const gmail = { uid: "gmail1", email: "someone@gmail.com" };
    await assertFails(getDoc(doc(as(gmail), "reports/r1")));
  });

  it("verified student reads reports -> allow", async () => {
    await seedReport();
    await assertSucceeds(getDoc(doc(as(STUDENT), "reports/r1")));
  });
});

describe("users", () => {
  it("first verified sign-in creates a student profile -> allow", async () => {
    const fresh = { uid: "student3", email: "chidi@alustudent.com", name: "Chidi Eze" };
    await assertSucceeds(
      setDoc(doc(as(fresh), `users/${fresh.uid}`), { ...userDoc(fresh), createdAt: serverTimestamp() }),
    );
  });

  it("first unverified sign-in creates a student profile -> allow", async () => {
    const fresh = { uid: "student3", email: "chidi@alustudent.com", name: "Chidi Eze" };
    await assertSucceeds(
      setDoc(doc(as(fresh, { verified: false }), `users/${fresh.uid}`), {
        ...userDoc(fresh),
        createdAt: serverTimestamp(),
      }),
    );
  });

  it("unverified staff-domain user creates a profile -> deny", async () => {
    const fresh = { uid: "staff2", email: "new@alueducation.com", name: "New Staff" };
    await assertFails(
      setDoc(doc(as(fresh, { verified: false }), `users/${fresh.uid}`), {
        ...userDoc(fresh),
        createdAt: serverTimestamp(),
      }),
    );
  });

  it("3. student creates users/{uid} with role staff -> deny", async () => {
    const fresh = { uid: "student3", email: "chidi@alustudent.com", name: "Chidi Eze" };
    await assertFails(
      setDoc(doc(as(fresh), `users/${fresh.uid}`), {
        ...userDoc(fresh, "staff"),
        createdAt: serverTimestamp(),
      }),
    );
  });

  it("student renames themselves -> allow", async () => {
    await assertSucceeds(updateDoc(doc(as(STUDENT), `users/${STUDENT.uid}`), { displayName: "Amina H." }));
  });

  it("student changes their own role -> deny", async () => {
    await assertFails(updateDoc(doc(as(STUDENT), `users/${STUDENT.uid}`), { role: "staff" }));
  });

  it("student reads another student's profile -> deny", async () => {
    await assertFails(getDoc(doc(as(STUDENT), `users/${OTHER.uid}`)));
  });
});

describe("create report (W2)", () => {
  it("valid report with history/initial in one batch -> allow", async () => {
    const db = as(STUDENT);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1"), newReportFields());
    batch.set(doc(db, "reports/r1/history/initial"), initialHistory());
    await assertSucceeds(batch.commit());
  });

  it("4a. report with upvoteCount 3 -> deny", async () => {
    const db = as(STUDENT);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1"), newReportFields({ upvoteCount: 3 }));
    batch.set(doc(db, "reports/r1/history/initial"), initialHistory());
    await assertFails(batch.commit());
  });

  it("4b. report with status inProgress -> deny", async () => {
    const db = as(STUDENT);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1"), newReportFields({ status: "inProgress" }));
    batch.set(doc(db, "reports/r1/history/initial"), initialHistory());
    await assertFails(batch.commit());
  });

  it("5. report without the history/initial doc -> deny", async () => {
    await assertFails(setDoc(doc(as(STUDENT), "reports/r1"), newReportFields()));
  });

  it("report with an extra key -> deny", async () => {
    const db = as(STUDENT);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1"), newReportFields({ sneaky: true }));
    batch.set(doc(db, "reports/r1/history/initial"), initialHistory());
    await assertFails(batch.commit());
  });

  it("staff creates a report -> deny", async () => {
    const db = as(STAFF);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1"), newReportFields({ reporterId: STAFF.uid, reporterName: STAFF.name }));
    batch.set(
      doc(db, "reports/r1/history/initial"),
      initialHistory({ actorId: STAFF.uid, actorName: STAFF.name }),
    );
    await assertFails(batch.commit());
  });
});

describe("edit report (W3)", () => {
  const edit = { title: "Leaking tap, 2nd floor", titleLower: "leaking tap, 2nd floor" };

  it("6. student edits own submitted report -> allow", async () => {
    await seedReport();
    await assertSucceeds(
      updateDoc(doc(as(STUDENT), "reports/r1"), { ...edit, updatedAt: serverTimestamp() }),
    );
  });

  it("7. student edits own report after it is inProgress -> deny", async () => {
    await seedReport({ status: "inProgress" });
    await assertFails(updateDoc(doc(as(STUDENT), "reports/r1"), { ...edit, updatedAt: serverTimestamp() }));
  });

  it("8. student edits another student's report -> deny", async () => {
    await seedReport();
    await assertFails(updateDoc(doc(as(OTHER), "reports/r1"), { ...edit, updatedAt: serverTimestamp() }));
  });

  it("9a. student changes status -> deny", async () => {
    await seedReport();
    await assertFails(
      updateDoc(doc(as(STUDENT), "reports/r1"), { status: "resolved", updatedAt: serverTimestamp() }),
    );
  });

  it("9b. student changes priority -> deny", async () => {
    await seedReport();
    await assertFails(
      updateDoc(doc(as(STUDENT), "reports/r1"), { priority: "urgent", updatedAt: serverTimestamp() }),
    );
  });
});

describe("votes (W6)", () => {
  it("another student votes with the vote doc and a +1 counter -> allow", async () => {
    await seedReport();
    const db = as(OTHER);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1/upvotes/student2"), { createdAt: serverTimestamp() });
    batch.update(doc(db, "reports/r1"), { upvoteCount: increment(1) });
    await assertSucceeds(batch.commit());
  });

  it("another student removes their vote with a -1 counter -> allow", async () => {
    await seedReport({ upvoteCount: 1 });
    await seed((db) => setDoc(doc(db, "reports/r1/upvotes/student2"), { createdAt: now() }));
    const db = as(OTHER);
    const batch = writeBatch(db);
    batch.delete(doc(db, "reports/r1/upvotes/student2"));
    batch.update(doc(db, "reports/r1"), { upvoteCount: increment(-1) });
    await assertSucceeds(batch.commit());
  });

  it("10. student votes on their own report -> deny", async () => {
    await seedReport();
    const db = as(STUDENT);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1/upvotes/student1"), { createdAt: serverTimestamp() });
    batch.update(doc(db, "reports/r1"), { upvoteCount: increment(1) });
    await assertFails(batch.commit());
  });

  it("11a. counter bumped without a vote doc -> deny", async () => {
    await seedReport();
    await assertFails(updateDoc(doc(as(OTHER), "reports/r1"), { upvoteCount: increment(1) }));
  });

  it("11b. counter changed by 2 -> deny", async () => {
    await seedReport();
    const db = as(OTHER);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1/upvotes/student2"), { createdAt: serverTimestamp() });
    batch.update(doc(db, "reports/r1"), { upvoteCount: increment(2) });
    await assertFails(batch.commit());
  });

  it("12. voting a second time -> deny", async () => {
    await seedReport({ upvoteCount: 1 });
    await seed((db) => setDoc(doc(db, "reports/r1/upvotes/student2"), { createdAt: now() }));
    const db = as(OTHER);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1/upvotes/student2"), { createdAt: serverTimestamp() });
    batch.update(doc(db, "reports/r1"), { upvoteCount: increment(1) });
    await assertFails(batch.commit());
  });

  it("staff votes -> deny", async () => {
    await seedReport();
    const db = as(STAFF);
    const batch = writeBatch(db);
    batch.set(doc(db, "reports/r1/upvotes/staff1"), { createdAt: serverTimestamp() });
    batch.update(doc(db, "reports/r1"), { upvoteCount: increment(1) });
    await assertFails(batch.commit());
  });
});

describe("staff update (W5)", () => {
  it("13. status and priority with matching history and notification -> allow", async () => {
    await seedReport();
    await assertSucceeds(staffUpdateBatch(as(STAFF)).commit());
  });

  it("14a. update with a note that is too short -> deny", async () => {
    await seedReport();
    await assertFails(staffUpdateBatch(as(STAFF), { note: "x" }).commit());
  });

  it("14b. update without a history entry -> deny", async () => {
    await seedReport();
    await assertFails(staffUpdateBatch(as(STAFF), { withHistory: false }).commit());
  });

  // Known gap: the report holds no pointer to the notification, so the rules cannot require it. The app always writes it. If the schema
  // gains a lastNotificationId, flip this to assertFails.
  it("known gap: update without the reporter's notification -> allowed", async () => {
    await seedReport();
    await assertSucceeds(staffUpdateBatch(as(STAFF), { withNotification: false }).commit());
  });

  it("student performs the same update -> deny", async () => {
    await seedReport();
    await assertFails(staffUpdateBatch(as(STUDENT)).commit());
  });

  it("15a. staff edits the title -> deny", async () => {
    await seedReport();
    await assertFails(
      updateDoc(doc(as(STAFF), "reports/r1"), {
        title: "Hacked title",
        titleLower: "hacked title",
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it("15b. staff deletes a report -> deny", async () => {
    await seedReport();
    await assertFails(deleteDoc(doc(as(STAFF), "reports/r1")));
  });

  it("16. staff creates a notification not tied to a report change -> deny", async () => {
    await seedReport();
    await assertFails(
      setDoc(doc(as(STAFF), "users/student1/notifications/n1"), notificationFields({ type: "statusChange" })),
    );
  });
});

describe("notifications (W7)", () => {
  beforeEach(() =>
    seed(async (db) => {
      await setDoc(doc(db, "users/student1/notifications/n1"), { ...notificationFields(), createdAt: now() });
    }),
  );

  it("17. student marks their own notification read -> allow", async () => {
    await assertSucceeds(updateDoc(doc(as(STUDENT), "users/student1/notifications/n1"), { read: true }));
  });

  it("18. student reads another user's notification -> deny", async () => {
    await assertFails(getDoc(doc(as(OTHER), "users/student1/notifications/n1")));
  });

  it("student edits the message of their notification -> deny", async () => {
    await assertFails(
      updateDoc(doc(as(STUDENT), "users/student1/notifications/n1"), { message: "Edited", read: true }),
    );
  });
});

describe("delete report (W4)", () => {
  async function seedSubdocs(overrides = {}) {
    await seedReport({ upvoteCount: 1, ...overrides });
    await seed(async (db) => {
      await setDoc(doc(db, "reports/r1/upvotes/student2"), { createdAt: now() });
      await setDoc(doc(db, "users/student1/notifications/n1"), { ...notificationFields(), createdAt: now() });
    });
  }

  function deleteEverything(db) {
    const batch = writeBatch(db);
    batch.delete(doc(db, "reports/r1/history/initial"));
    batch.delete(doc(db, "reports/r1/upvotes/student2"));
    batch.delete(doc(db, "users/student1/notifications/n1"));
    batch.delete(doc(db, "reports/r1"));
    return batch;
  }

  it("19. owner deletes a submitted report with its subdocs in one batch -> allow", async () => {
    await seedSubdocs();
    await assertSucceeds(deleteEverything(as(STUDENT)).commit());
  });

  it("20. same, after the status is resolved -> deny", async () => {
    await seedSubdocs({ status: "resolved" });
    await assertFails(deleteEverything(as(STUDENT)).commit());
  });

  it("another student deletes the report -> deny", async () => {
    await seedSubdocs();
    await assertFails(deleteEverything(as(OTHER)).commit());
  });

  it("21a. student updates a history entry alone -> deny", async () => {
    await seedReport();
    await assertFails(updateDoc(doc(as(STUDENT), "reports/r1/history/initial"), { note: "Edited" }));
  });

  it("21b. student deletes a history entry alone -> deny", async () => {
    await seedReport();
    await assertFails(deleteDoc(doc(as(STUDENT), "reports/r1/history/initial")));
  });
});

describe("22-23. photo uploads", () => {
  it("22. 6 MB / image/png / another user's path", { skip: "Storage rules were dropped; photos use Supabase" }, () => {});
  it("23. upload for a report that is no longer submitted", { skip: "Storage rules were dropped; photos use Supabase" }, () => {});
});
