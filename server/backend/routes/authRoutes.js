const express = require("express");
const router = express.Router();

const {
  sendSignupOtp,
  verifySignupOtp,
  resendSignupOtp,
  loginUser,
  googleSignIn,
  getProfile,
  updateUserProfile,
  changePassword,
  forgotPassword,
  verifyOtp,
  resendOtp,
  resetPassword,
  deleteAccount,
} = require("../controllers/authController");

const authMiddleware = require("../middleware/authMiddleware");

// ==========================
// PUBLIC ROUTES
// ==========================

// Signup Flow (2-step OTP verification)
router.post("/send-signup-otp", sendSignupOtp);
router.post("/verify-signup-otp", verifySignupOtp);
router.post("/resend-signup-otp", resendSignupOtp);

// Login
router.post("/login", loginUser);

// Google Sign-In
router.post("/google-signin", googleSignIn);

// Forgot Password Flow
router.post("/forgot-password", forgotPassword);
router.post("/verify-otp", verifyOtp);
router.post("/resend-otp", resendOtp);
router.post("/reset-password", resetPassword);

// Delete Account
router.delete("/delete-account", authMiddleware, deleteAccount);

// ==========================
// PROTECTED ROUTES
// ==========================
router.get("/profile", authMiddleware, getProfile);
router.put("/update-profile", authMiddleware, updateUserProfile);
router.put("/change-password", authMiddleware, changePassword);

module.exports = router;