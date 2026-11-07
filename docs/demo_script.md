# Android demonstration script (7–10 minutes)

Use a real Android emulator or physical device connected to the Firebase project configured for this assignment. Prepare separate verified student and administrator-assigned staff test accounts. Do not show passwords, API keys, service-account credentials, private user data, or unrelated Firebase records.

## 1. Introduction (30–45 seconds)

Introduce the campus problem the app addresses. Explain that students submit campus incidents and follow their progress, while authorized staff review reports and update their status.

## 2. Student registration and email verification (about 1 minute)

Show registration with a valid `@alustudent.com` test email. Point out the name, email, and password validation. Open the verification email and verify the account. Explain that incident operations require a verified ALU address.

## 3. Student sign-in and dashboard (about 45 seconds)

Sign in with the verified student account. Show the dashboard and report summary. Explain that the student feed is restricted to the signed-in user's own reports.

## 4. Submit an incident with a photo (about 1–1.5 minutes)

Open the incident form. Select a category, enter a concise title, description, and campus location. Attach a real photo using the camera or gallery and submit. Explain that the image is uploaded to Firebase Storage and report metadata is stored in Cloud Firestore.

## 5. Browse, search, and filter (about 1 minute)

Open the report list. Search by title, description, category, or location, then filter by status. Show that a student account cannot browse another student's report.

## 6. Inspect report details (about 45 seconds)

Open the newly submitted report. Show the image, category, description, location, creation date, and status timeline. While the report is still `Submitted`, show the owner's edit/delete controls.

## 7. Staff review and status progression (about 1.5 minutes)

Sign out and sign in with the separate verified staff account whose `users/{uid}.role` field was assigned by a trusted Firebase administrator. Show the staff queue. Open the student's test report and advance it from `Submitted` to `In Progress`, then to `Resolved`. Explain that staff cannot move status backwards and that the student sees the updated status through the Firestore feed.

## 8. Firebase records and security (about 1 minute)

Show the Firebase Authentication test account, its user profile document, the incident document, and the uploaded photo path. Explain that Firestore and Storage rules enforce verified-email, ownership, and staff-role checks independently of route visibility. Hide emails, UIDs, download tokens, and project identifiers that should not be public.

## 9. Architecture and conclusion (about 45 seconds)

Explain the main flow: Flutter screen → Provider → Repository → Firebase service. Mention email verification, ownership, optional photo storage, forward-only status progression, and the separation between student and staff permissions. Conclude with the benefit to campus issue reporting.

## Recording checklist

- [ ] Record on the real Android app, not a browser-only build.
- [ ] Show registration, verification, and sign-in.
- [ ] Show a report saved to Firestore with a photo uploaded to Storage.
- [ ] Show browse/search/filter and incident details.
- [ ] Show the staff account progressing the report status.
- [ ] Show the updated status in the student account.
- [ ] Keep private information and credentials hidden.
- [ ] Upload the recording and add its accessible URL to `docs/technical_report.md`.