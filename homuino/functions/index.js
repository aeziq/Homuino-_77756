const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.checkDeviceStatus = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async (context) => {
    const now = Date.now();
    const offlineThreshold = 30 * 1000; // 30 seconds
    const ref = admin.database().ref("devices");

    const snapshot = await ref.once("value");
    const updates = {};

    snapshot.forEach((child) => {
      const data = child.val();
      const lastSeen = data.lastSeen || 0;
      const isStale = now - lastSeen > offlineThreshold;

      if (isStale && data.status !== "OFFLINE") {
        updates[`${child.key}/status`] = "OFFLINE";
        console.log(`Setting ${child.key} to OFFLINE`);
      }
    });

    if (Object.keys(updates).length > 0) {
      await ref.update(updates);
    }

    return null;
  });
