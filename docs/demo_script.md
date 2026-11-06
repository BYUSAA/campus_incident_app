# Android demonstration script (approximately 7–10 minutes)

Use a real Android emulator or physical device connected to the configured Firebase project. Create separate student and staff test accounts before recording. Do not show passwords, API keys, private user data, or unrelated Firebase records.

## 1. Introduction (30–45 seconds)

Introduce the campus problem the app addresses. Explain that students can submit incident reports and follow their status, while authorized staff can review the incident queue and update reports.

## 2. Student account registration (about 1 minute)

Open the app and show the registration screen. Register a test account using an `@alustudent.com` address. Point out the required name, email, and password validation. Open the verification email and complete the verification process.

## 3. Student sign-in and home screen (about 45 seconds)

Sign in with the verified test account. Show the home screen and explain that the report summary is calculated from the reports currently loaded for this account.

## 4. Create an incident (about 1–1.5 minutes)

Open the incident form. Select a category, enter a clear title, description, and campus location. Attach a photo from the gallery or camera and submit the report. Explain that the image is stored in Firebase Storage and the report metadata is stored in Cloud Firestore.

## 5. Browse, search, and filter (about 1 minute)

Open the reports list. Search by a title, description, category, or location. Use the status filter. Show that the student account sees only its own reports.

## 6. Open report details (about 45 seconds)

Open the newly submitted report. Show the image, report information, creation date, location, and status timeline. While it remains Submitted, show how the owner can edit or delete the report.

## 7. Staff review and status update (about 1–1.5 minutes)

Sign out. Sign in with the separate staff test account whose `users/{uid}.role` field has been assigned to `staff` by the Firebase project administrator. Show the staff dashboard and open the submitted report. Change its status to In Progress and then Resolved, explaining that the student can see the updated status on the next report refresh.

## 8. Firebase records and security (about 1 minute)

Show the Authentication account, the corresponding `users/{uid}` profile, the incident document, and the uploaded image path. Explain that Firestore and Storage rules enforce the role and ownership checks independently of the UI. Hide private emails, user IDs, and project identifiers in the recording.

## 9. Architecture and conclusion (about 45 seconds)

Briefly explain the flow: Flutter screen → Provider → Repository → Firebase service. Mention email verification, student/staff role separation, report ownership, optional photo uploads, and status tracking. Conclude with the main benefit to campus reporting.

## Recording checklist

- [ ] Use the actual running Android app.
- [ ] Show a student report being saved and retrieved from Firestore.
- [ ] Show the optional photo upload working.
- [ ] Show search and status filtering.
- [ ] Show a separate staff account changing the report status.
- [ ] Keep credentials and personal data hidden.
- [ ] Upload the video and add its accessible URL to `docs/technical_report.md`.
