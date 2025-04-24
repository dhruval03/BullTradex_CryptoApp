// routes/userRoutes.js
const express = require("express");
const router = express.Router();
const authenticateToken = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");
const { getProfile, updateProfile, uploadProfileImage } = require("../controllers/userController");

// Get user profile
router.get("/profile", authenticateToken, getProfile);

// Update user profile
router.put("/profile", authenticateToken, updateProfile);

// Upload profile image - dedicated endpoint
router.post("/profile/image", authenticateToken, upload.single('profileImage'), uploadProfileImage);

// Combined update endpoint - can also handle image upload
router.put("/profile/with-image", authenticateToken, upload.single('profileImage'), updateProfile);

module.exports = router;