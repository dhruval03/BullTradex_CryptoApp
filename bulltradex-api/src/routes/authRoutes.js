const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { createUser, getUserByEmail } = require("../models/userModel");
const authenticateToken = require("../middleware/authMiddleware");

const { getProfile, updateProfile } = require("../controllers/userController");
const router = express.Router();

const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

router.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const existingUser = await getUserByEmail(email);

    if (!emailRegex.test(email)) {
      return res.status(400).json({ message: "Invalid email format" });
    }
    
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await createUser(name, email, hashedPassword);

    res.status(201).json({ message: "User created successfully", user });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    let { email, password } = req.body;
    email = email.trim().toLowerCase();
    console.log("📥 Login attempt for:", email);

    const user = await getUserByEmail(email);
    if (!user) {
      console.log("❌ User not found");
      return res.status(401).json({ message: "Invalid credentials" });
    }

    console.log("✅ User found:", user.email);

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log("❌ Password does not match");
      return res.status(401).json({ message: "Invalid credentials" });
    }

    console.log("🔐 Password matched");

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: "1h",
    });
 
    console.log("🎫 Token generated");

    res.status(200).json({ token });
  } catch (error) {
    console.error("💥 Login error:", error.message);
    res.status(500).json({ message: "Server error" });
  }
});


// 🔐 Protected Route Example
router.get("/profile", authenticateToken, async (req, res) => {
  try {
    const user = await getUserByEmail(req.user.id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json({ user });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});
router.get("/profile", authenticateToken, getProfile);
router.put("/profile", authenticateToken, updateProfile);
module.exports = router;
