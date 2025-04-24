// controllers/userController.js
const { getUserById, updateUser } = require("../models/userModel");
const bcrypt = require("bcrypt");
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const fs = require('fs');
const path = require('path');

exports.getProfile = async (req, res) => {
  try {
    const user = await getUserById(req.user.userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    const { password, ...safeUser } = user; // Exclude password
    
    // Add full image URL if profile image exists
    if (safeUser.profile_image) {
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      safeUser.profile_image_url = `${baseUrl}/uploads/profile_images/${safeUser.profile_image}`;
    }
    
    res.json(safeUser);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    if (!name && !email && !password && !req.file) {
      return res.status(400).json({ message: "No fields to update" });
    }

    if (email && !emailRegex.test(email)) {
      return res.status(400).json({ message: "Invalid email format" });
    }

    let hashedPassword;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    // Handle profile image
    let profileImage = undefined;
    if (req.file) {
      profileImage = req.file.filename;
      
      // Delete old profile image if it exists
      const user = await getUserById(req.user.userId);
      if (user && user.profile_image) {
        const oldImagePath = path.join(__dirname, '../public/uploads/profile_images', user.profile_image);
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }
    }

    const updatedUser = await updateUser(req.user.userId, {
      name,
      email,
      password: hashedPassword,
      profileImage
    });

    const { password: pw, ...safeUser } = updatedUser;
    
    // Add full image URL if profile image exists
    if (safeUser.profile_image) {
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      safeUser.profile_image_url = `${baseUrl}/uploads/profile_images/${safeUser.profile_image}`;
    }
    
    res.json({ message: "Profile updated", user: safeUser });
  } catch (error) {
    res.status(500).json({ message: "Update failed", error: error.message });
  }
};

exports.uploadProfileImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }

    // Get existing user
    const user = await getUserById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Delete old profile image if it exists
    if (user.profile_image) {
      const oldImagePath = path.join(__dirname, '../public/uploads/profile_images', user.profile_image);
      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
    }

    // Update user with new profile image
    const updatedUser = await updateUser(req.user.userId, {
      profileImage: req.file.filename
    });

    const { password, ...safeUser } = updatedUser;
    
    // Add full image URL
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    safeUser.profile_image_url = `${baseUrl}/uploads/profile_images/${safeUser.profile_image}`;

    res.json({ 
      message: "Profile image updated", 
      user: safeUser
    });
  } catch (error) {
    res.status(500).json({ message: "Image upload failed", error: error.message });
  }
};