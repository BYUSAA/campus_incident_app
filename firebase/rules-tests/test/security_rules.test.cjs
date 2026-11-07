const { readFileSync } = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');
const {
  deleteObject,
  getBytes,
  ref,
  uploadBytes,
} = require('firebase/storage');
const { describe, it, before, beforeEach, after } = require('mocha');

const projectId = 'demo-campus-incident-reporter';
const validEmail = (uid) => `${uid}@alustudent.com`;
const incidentData = (uid, status = 'Submitted') => ({
  title: 'Leaking water tap',
  description: 'Water is leaking near the student residence.',
  category: 'Water',
  location: 'Student Residence, Block B',
  reportedBy: uid,
  reporterName: 'Test Student',
  status,
  createdAt: new Date(),
  updatedAt: new Date(),
  imageUrl: null,
  photoUrls: [],
  assignedTo: null,
});

describe('Campus Incident Reporter Firebase security rules', function () {
  let testEnv;

  before(async function () {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: readFileSync(
          path.resolve(__dirname, '../../firestore.rules'),
          'utf8',
        ),
      },
      storage: {
        rules: readFileSync(
          path.resolve(__dirname, '../../storage.rules'),
          'utf8',
        ),
      },
    });
  });

  beforeEach(async function () {
    await testEnv.clearFirestore();
    await testEnv.clearStorage();

    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'users', 'staff-1'), {
        uid: 'staff-1',
        name: 'Authorized Staff',
        email: validEmail('staff-1'),
        role: 'staff',
        emailVerified: true,
      });
      await setDoc(doc(context.firestore(), 'users', 'student-1'), {
        uid: 'student-1',
        name: 'Student One',
        email: validEmail('student-1'),
        role: 'student',
        emailVerified: true,
      });
      await setDoc(doc(context.firestore(), 'users', 'student-2'), {
        uid: 'student-2',
        name: 'Student Two',
        email: validEmail('student-2'),
        role: 'student',
        emailVerified: true,
      });

      await setDoc(
        doc(context.firestore(), 'incidents', 'submitted-report'),
        incidentData('student-1', 'Submitted'),
      );
      await setDoc(
        doc(context.firestore(), 'incidents', 'in-progress-report'),
        incidentData('student-1', 'In Progress'),
      );
      await setDoc(
        doc(context.firestore(), 'incidents', 'another-student-report'),
        incidentData('student-2', 'Submitted'),
      );
    });
  });

  after(async function () {
    await testEnv.cleanup();
  });

  function student(uid = 'student-1', emailVerified = true) {
    return testEnv.authenticatedContext(uid, {
      email: validEmail(uid),
      email_verified: emailVerified,
    });
  }

  function staff() {
    return testEnv.authenticatedContext('staff-1', {
      email: validEmail('staff-1'),
      email_verified: true,
    });
  }

  describe('Firestore: ALU identity and ownership', function () {
    it('allows an unverified ALU user to create only a student profile', async function () {
      const db = student('new-student', false).firestore();
      const profile = {
        uid: 'new-student',
        name: 'New Student',
        email: validEmail('new-student'),
        role: 'student',
        emailVerified: false,
        createdAt: serverTimestamp(),
      };

      await assertSucceeds(setDoc(doc(db, 'users', 'new-student'), profile));
    });

    it('does not allow a student to promote their own role', async function () {
      const db = student().firestore();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'student-1'), {
          uid: 'student-1',
          name: 'Student One',
          email: validEmail('student-1'),
          role: 'student',
          emailVerified: true,
        });
      });

      await assertFails(
        updateDoc(doc(db, 'users', 'student-1'), { role: 'staff' }),
      );
    });

    it('keeps student profile documents private from other users and staff', async function () {
      const studentDb = student().firestore();
      const staffDb = staff().firestore();

      await assertSucceeds(getDoc(doc(studentDb, 'users', 'student-1')));
      await assertFails(getDoc(doc(studentDb, 'users', 'student-2')));
      await assertSucceeds(getDoc(doc(staffDb, 'users', 'staff-1')));
      await assertFails(getDoc(doc(staffDb, 'users', 'student-1')));
    });

    it('allows students to read their own report, not another student report', async function () {
      const db = student().firestore();

      await assertSucceeds(
        getDoc(doc(db, 'incidents', 'submitted-report')),
      );
      await assertFails(
        getDoc(doc(db, 'incidents', 'another-student-report')),
      );
    });

    it('requires an ownership filter for student report lists', async function () {
      const db = student().firestore();

      await assertFails(getDocs(collection(db, 'incidents')));
      await assertSucceeds(
        getDocs(
          query(
            collection(db, 'incidents'),
            where('reportedBy', '==', 'student-1'),
          ),
        ),
      );
    });

    it('denies incident access to an unverified ALU account', async function () {
      const db = student('student-1', false).firestore();
      await assertFails(
        getDoc(doc(db, 'incidents', 'submitted-report')),
      );
    });
  });

  describe('Firestore: incident lifecycle', function () {
    it('allows a student to create a valid Submitted report', async function () {
      const db = student().firestore();
      const payload = {
        ...incidentData('student-1'),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      };

      await assertSucceeds(
        setDoc(doc(db, 'incidents', 'new-student-report'), payload),
      );
    });

    it('rejects invalid categories and oversized report text', async function () {
      const db = student().firestore();
      const invalidCategory = {
        ...incidentData('student-1'),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        category: 'Other',
      };
      const oversizedTitle = {
        ...incidentData('student-1'),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        title: 'x'.repeat(101),
      };

      await assertFails(
        setDoc(doc(db, 'incidents', 'invalid-category'), invalidCategory),
      );
      await assertFails(
        setDoc(doc(db, 'incidents', 'oversized-title'), oversizedTitle),
      );
    });

    it('allows a student to edit content only while Submitted', async function () {
      const db = student().firestore();

      await assertSucceeds(
        updateDoc(doc(db, 'incidents', 'submitted-report'), {
          title: 'Updated leaking tap',
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(
        updateDoc(doc(db, 'incidents', 'in-progress-report'), {
          title: 'Attempted edit after processing',
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('does not allow a student to change the report status', async function () {
      const db = student().firestore();

      await assertFails(
        updateDoc(doc(db, 'incidents', 'submitted-report'), {
          status: 'Resolved',
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('allows students to delete only their own Submitted reports', async function () {
      const db = student().firestore();

      await assertSucceeds(
        deleteDoc(doc(db, 'incidents', 'submitted-report')),
      );
      await assertFails(
        deleteDoc(doc(db, 'incidents', 'in-progress-report')),
      );
      await assertFails(
        deleteDoc(doc(db, 'incidents', 'another-student-report')),
      );
    });

    it('allows staff to read all reports and move status forward', async function () {
      const db = staff().firestore();

      const allReports = await assertSucceeds(
        getDocs(collection(db, 'incidents')),
      );
      if (allReports.size !== 3) {
        throw new Error(`Expected 3 reports, received ${allReports.size}`);
      }

      await assertSucceeds(
        updateDoc(doc(db, 'incidents', 'submitted-report'), {
          status: 'In Progress',
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it('does not allow staff to move a Resolved report backwards', async function () {
      const db = staff().firestore();

      await assertFails(
        updateDoc(doc(db, 'incidents', 'in-progress-report'), {
          status: 'Submitted',
          updatedAt: serverTimestamp(),
        }),
      );
    });
  });

  describe('Storage: upload ownership and staff evidence access', function () {
    it('allows an ALU owner to upload an allowed image', async function () {
      const storage = student().storage();
      const imageRef = ref(storage, 'incident_photos/student-1/report.jpg');

      await assertSucceeds(
        uploadBytes(imageRef, new Uint8Array([1, 2, 3]), {
          contentType: 'image/jpeg',
        }),
      );
    });

    it('does not allow a student to upload into another user folder', async function () {
      const storage = student().storage();
      const imageRef = ref(storage, 'incident_photos/student-2/report.jpg');

      await assertFails(
        uploadBytes(imageRef, new Uint8Array([1, 2, 3]), {
          contentType: 'image/jpeg',
        }),
      );
    });

    it('rejects non-image content types', async function () {
      const storage = student().storage();
      const fileRef = ref(storage, 'incident_photos/student-1/document.txt');

      await assertFails(
        uploadBytes(fileRef, new Uint8Array([1, 2, 3]), {
          contentType: 'text/plain',
        }),
      );
    });

    it('rejects files at or above the 8 MB limit', async function () {
      const storage = student().storage();
      const fileRef = ref(storage, 'incident_photos/student-1/oversized.jpg');
      const oversizedBytes = new Uint8Array(8 * 1024 * 1024);

      await assertFails(
        uploadBytes(fileRef, oversizedBytes, {
          contentType: 'image/jpeg',
        }),
      );
    });

    it('allows authorized staff to read and delete uploaded evidence', async function () {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await uploadBytes(
          ref(context.storage(), 'incident_photos/student-1/staff-review.jpg'),
          new Uint8Array([7, 8, 9]),
          { contentType: 'image/jpeg' },
        );
      });

      const staffStorage = staff().storage();
      const evidenceRef = ref(
        staffStorage,
        'incident_photos/student-1/staff-review.jpg',
      );

      await assertSucceeds(getBytes(evidenceRef));
      await assertSucceeds(deleteObject(evidenceRef));
    });
  });
});
