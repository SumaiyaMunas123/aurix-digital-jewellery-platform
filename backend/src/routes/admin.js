import express from "express";
import { adminLogin } from "../controllers/adminLogin.js";
import { requireAuth, requireAdmin } from "../middleware/auth.js";
import { supabase } from "../config/supabaseClient.js";
import {
  getPendingJewellers,
  getAllJewellers,
  getJewellerStatus,
  approveJeweller,
  rejectJeweller,
  getPlatformStats,
} from "../controllers/adminController.js";
import {
  adminGetAllProducts,
  adminGetProductById,
  adminApproveProduct,
  adminRejectProduct,
  adminDeleteProduct,
  adminToggleProductVisibility,
  adminGetProductStats,
  adminGetProductsByJeweller,
} from "../controllers/adminProductController.js";
import {
  adminGetAllOrders,
  adminGetOrderById,
  adminGetOrderStats,
  adminUpdateOrderStatus,
  adminDeleteOrder,
} from "../controllers/adminOrderController.js";

const router = express.Router();

router.post("/login", adminLogin);

router.get("/verify", requireAuth, requireAdmin, (req, res) => {
  return res.status(200).json({ success: true, user: req.user });
});

router.get("/jewellers", requireAuth, requireAdmin, getAllJewellers);
router.get(
  "/jewellers/pending",
  requireAuth,
  requireAdmin,
  getPendingJewellers,
);
router.get(
  "/jewellers/:jeweller_id/status",
  requireAuth,
  requireAdmin,
  getJewellerStatus,
);
router.put(
  "/jewellers/:jeweller_id/approve",
  requireAuth,
  requireAdmin,
  approveJeweller,
);
router.put(
  "/jewellers/:jeweller_id/reject",
  requireAuth,
  requireAdmin,
  rejectJeweller,
);

router.get("/stats", requireAuth, requireAdmin, getPlatformStats);

router.get("/orders/chart", requireAuth, requireAdmin, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("orders")
      .select("created_at")
      .gte(
        "created_at",
        new Date(new Date().setMonth(new Date().getMonth() - 5)).toISOString(),
      );

    if (error) throw error;

    const months = [];
    for (let i = 5; i >= 0; i--) {
      const d = new Date();
      d.setDate(1);
      d.setMonth(d.getMonth() - i);
      months.push({
        key: `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`,
        label: d.toLocaleString("en-US", { month: "short" }),
        count: 0,
      });
    }

    (data || []).forEach((order) => {
      const d = new Date(order.created_at);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
      const month = months.find((m) => m.key === key);
      if (month) month.count++;
    });

    return res.status(200).json({ success: true, chart: months });
  } catch (error) {
    console.error("orders/chart error:", error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get("/products/stats", requireAuth, requireAdmin, adminGetProductStats);

router.get("/products", requireAuth, requireAdmin, adminGetAllProducts);

router.get("/products/:id", requireAuth, requireAdmin, adminGetProductById);

router.patch(
  "/products/:id/approve",
  requireAuth,
  requireAdmin,
  adminApproveProduct,
);

router.patch(
  "/products/:id/reject",
  requireAuth,
  requireAdmin,
  adminRejectProduct,
);

router.delete("/products/:id", requireAuth, requireAdmin, adminDeleteProduct);

router.patch(
  "/products/:id/visibility",
  requireAuth,
  requireAdmin,
  adminToggleProductVisibility,
);

router.get(
  "/jewellers/:jeweller_id/products",
  requireAuth,
  requireAdmin,
  adminGetProductsByJeweller,
);

router.get("/orders/stats", requireAuth, requireAdmin, adminGetOrderStats);
router.get("/orders", requireAuth, requireAdmin, adminGetAllOrders);
router.get("/orders/:id", requireAuth, requireAdmin, adminGetOrderById);
router.patch(
  "/orders/:id/status",
  requireAuth,
  requireAdmin,
  adminUpdateOrderStatus,
);
router.delete("/orders/:id", requireAuth, requireAdmin, adminDeleteOrder);

export default router;
