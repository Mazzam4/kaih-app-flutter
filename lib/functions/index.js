import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";

admin.initializeApp();

export const deleteExpiredUploads = onSchedule("every 24 hours", async (event) => {
  const db = admin.firestore();
  const storage = admin.storage();
  const now = new Date();

  const snapshot = await db.collection("habits_uploads")
    .where("expireAt", "<=", now)
    .get();

  console.log(`🧹 Menghapus ${snapshot.size} data kedaluwarsa...`);

  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.photoUrl) {
      try {
        const path = decodeURIComponent(data.photoUrl.split("/o/")[1].split("?")[0]);
        await storage.bucket().file(path).delete();
        console.log(`🗑️ File dihapus: ${path}`);
      } catch (error) {
        console.error("Gagal hapus file:", error);
      }
    }
    await doc.ref.delete();
  }

  console.log("✅ Selesai hapus data kedaluwarsa.");
});
