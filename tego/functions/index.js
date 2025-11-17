const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// When a sale is created, increment counters on the user document
exports.onSaleCreate = functions.firestore
  .document('users/{userId}/sales/{saleId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const data = snap.data() || {};
    const amount = typeof data.amount === 'number' ? data.amount : parseFloat(data.amount) || 0;

    const userRef = db.doc(`users/${userId}`);
    try {
      await userRef.set({
        totalSalesCount: admin.firestore.FieldValue.increment(1),
        totalAmount: admin.firestore.FieldValue.increment(amount),
        todaySalesCount: admin.firestore.FieldValue.increment(1),
        lastSaleAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    } catch (err) {
      console.error('onSaleCreate error', err);
    }
  });

// When a sale is deleted, decrement counters
exports.onSaleDelete = functions.firestore
  .document('users/{userId}/sales/{saleId}')
  .onDelete(async (snap, context) => {
    const { userId } = context.params;
    const data = snap.data() || {};
    const amount = typeof data.amount === 'number' ? data.amount : parseFloat(data.amount) || 0;

    const userRef = db.doc(`users/${userId}`);
    try {
      await userRef.set({
        totalSalesCount: admin.firestore.FieldValue.increment(-1),
        totalAmount: admin.firestore.FieldValue.increment(-amount),
      }, { merge: true });
    } catch (err) {
      console.error('onSaleDelete error', err);
    }
  });

// When a sale is updated, adjust totals by the delta
exports.onSaleUpdate = functions.firestore
  .document('users/{userId}/sales/{saleId}')
  .onUpdate(async (change, context) => {
    const { userId } = context.params;
    const before = change.before.data() || {};
    const after = change.after.data() || {};
    const beforeAmt = typeof before.amount === 'number' ? before.amount : parseFloat(before.amount) || 0;
    const afterAmt = typeof after.amount === 'number' ? after.amount : parseFloat(after.amount) || 0;
    const delta = afterAmt - beforeAmt;

    if (delta === 0) return null;

    const userRef = db.doc(`users/${userId}`);
    try {
      await userRef.set({
        totalAmount: admin.firestore.FieldValue.increment(delta),
      }, { merge: true });
    } catch (err) {
      console.error('onSaleUpdate error', err);
    }
    return null;
  });

// Scheduled function to reset todaySalesCount at midnight UTC daily
exports.resetTodaySalesCount = functions.pubsub.schedule('0 0 * * *').onRun(async (context) => {
  console.log('Resetting todaySalesCount for all users');
  const usersSnap = await db.collection('users').get();
  const batchSize = 500;
  let batch = db.batch();
  let ops = 0;
  for (const doc of usersSnap.docs) {
    batch.update(doc.ref, { todaySalesCount: 0 });
    ops++;
    if (ops >= batchSize) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }
  if (ops > 0) await batch.commit();
  console.log('Reset complete');
  return null;
});
