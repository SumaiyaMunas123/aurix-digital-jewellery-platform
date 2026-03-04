import express from "express";
import { adminLogin } from "../controllers/adminLogin.js";
import supabase from "../config/supabaseClient.js";

const router = express.Router();

router.post("/login", adminLogin);

export default router;