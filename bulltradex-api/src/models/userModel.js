// models/userModel.js
const pool = require("../config/db");

// ✅ Create a new user
const createUser = async (name, email, password) => {
  const result = await pool.query(
    "INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING *",
    [name, email, password]
  );
  return result.rows[0];
};

// ✅ Get user by email
const getUserByEmail = async (email) => {
  const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
  return result.rows[0];
};

// ✅ Get user by ID
const getUserById = async (id) => {
  const result = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
  return result.rows[0];
};

// ✅ Update user
const updateUser = async (id, { name, email, password, profileImage }) => {
  let fields = [];
  let values = [];
  let index = 1;

  if (name) {
    fields.push(`name = $${index++}`);
    values.push(name);
  }

  if (email) {
    fields.push(`email = $${index++}`);
    values.push(email);
  }

  if (password) {
    fields.push(`password = $${index++}`);
    values.push(password);
  }
  
  if (profileImage) {
    fields.push(`profile_image = $${index++}`);
    values.push(profileImage);
  }

  if (fields.length === 0) {
    throw new Error("No fields to update");
  }

  values.push(id); // Last value is ID

  const query = `
    UPDATE users SET ${fields.join(", ")} WHERE id = $${index} RETURNING *;
  `;

  const result = await pool.query(query, values);
  return result.rows[0];
};

// ✅ Export all functions
module.exports = {
  createUser,
  getUserByEmail,
  getUserById,
  updateUser,
};