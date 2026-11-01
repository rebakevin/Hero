// One-off: verify a staff Auth user and create its Firestore users/{uid} doc.
// Uses your existing `firebase login` through firebase-tools itself; no token is printed or stored.
// Usage: node scripts/seed-staff.js <staff@alueducation.com> ["Display Name"]
// The Auth user must already exist (create it in the Firebase Console first).
const { execSync } = require("child_process");
const ROOT = execSync("npm root -g").toString().trim() + "/firebase-tools";
const { requireAuth } = require(ROOT + "/lib/requireAuth");
const { getGlobalDefaultAccount } = require(ROOT + "/lib/auth");
const { Client } = require(ROOT + "/lib/apiv2");

const PROJECT = "hero-e61aa";
const EMAIL = process.argv[2] || "kevin@alueducation.com";
const DISPLAY_NAME = process.argv[3] || "Staff";

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account) throw new Error("Not logged in. Run `firebase login` first.");
  console.log("Using Firebase CLI account:", account.user.email);
  await requireAuth({ project: PROJECT, user: account.user, tokens: account.tokens });

  const idt = new Client({ urlPrefix: "https://identitytoolkit.googleapis.com", auth: true });
  const lookup = await idt.post(`/v1/projects/${PROJECT}/accounts:lookup`, { email: [EMAIL] });
  const user = lookup.body.users && lookup.body.users[0];
  if (!user) throw new Error(`No Auth user found for ${EMAIL}`);
  const uid = user.localId;
  console.log("Found user", uid);

  await idt.post(`/v1/projects/${PROJECT}/accounts:update`, { localId: uid, emailVerified: true });
  console.log("emailVerified set to true");

  const fs = new Client({ urlPrefix: "https://firestore.googleapis.com", auth: true });
  await fs.patch(`/v1/projects/${PROJECT}/databases/(default)/documents/users/${uid}`, {
    fields: {
      displayName: { stringValue: DISPLAY_NAME },
      email: { stringValue: EMAIL },
      role: { stringValue: "staff" },
      createdAt: { timestampValue: new Date().toISOString() },
    },
  });
  console.log(`users/${uid} created with role=staff`);
}

main().catch((e) => {
  console.error("FAILED:", e.message || e);
  process.exit(1);
});
