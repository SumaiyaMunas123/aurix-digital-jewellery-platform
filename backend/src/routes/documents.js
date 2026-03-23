import express from "express";
import { requireAuth, requireAdmin } from "../middleware/auth.js";
import {
  saveDocumentUrls,
  getMyDocuments,
  getJewellerDocuments,
  addDocumentFeedback,
  getAdminLogs,
} from "../controllers/documentController.js";

const router = express.Router();

// Jeweller routes (authenticated jeweller) 
router.post("/my/save", requireAuth, saveDocumentUrls);
router.get("/my", requireAuth, getMyDocuments);

// Admin routes 
router.get("/:jeweller_id", requireAuth, getJewellerDocuments);
router.post(
  "/:jeweller_id/feedback",
  requireAuth,
  requireAdmin,
  addDocumentFeedback,
);
router.get("/:jeweller_id/logs", requireAuth, getAdminLogs);

export default router;