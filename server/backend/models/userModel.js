const pool = require("../config/db");

// ==========================
// CREATE USER
// ==========================
const createUser = async (name, email, phone, hashedPassword) => {
  const result = await pool.query(
    `INSERT INTO users (name, email, phone, password) 
     VALUES ($1, $2, $3, $4) 
     RETURNING id, name, email, phone, created_at`,
    [name, email, phone, hashedPassword]
  );
  return result.rows[0];
};

// ==========================
// FIND USER BY EMAIL
// ==========================
const findUserByEmail = async (email) => {
  const result = await pool.query(
    `SELECT * FROM users WHERE email = $1`,
    [email]
  );
  return result.rows[0];
};

// ==========================
// FIND USER BY ID
// ==========================
const findUserById = async (id) => {
  const result = await pool.query(
    `SELECT id, name, email, phone, created_at FROM users WHERE id = $1`,
    [id]
  );
  return result.rows[0];
};

// ==========================
// FIND USER BY ID (WITH PASSWORD)
// ==========================
const findUserByIdWithPassword = async (id) => {
  const result = await pool.query(
    `SELECT * FROM users WHERE id = $1`,
    [id]
  );
  return result.rows[0];
};

// ==========================
// UPDATE PASSWORD
// ==========================
const updatePassword = async (email, hashedPassword) => {
  const result = await pool.query(
    `UPDATE users SET password = $1 WHERE email = $2 
     RETURNING id, name, email`,
    [hashedPassword, email]
  );
  return result.rows[0];
};

// ==========================
// UPDATE PROFILE
// ==========================
const updateProfile = async (id, name, email, phone) => {
  const result = await pool.query(
    `UPDATE users SET name = $1, email = $2, phone = $3 WHERE id = $4 
     RETURNING id, name, email, phone`,
    [name, email, phone, id]
  );
  return result.rows[0];
};

// ==========================
// DELETE USER
// ==========================
const deleteUser = async (id) => {
  await pool.query(`DELETE FROM users WHERE id = $1`, [id]);
};

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
  findUserByIdWithPassword,
  updatePassword,
  updateProfile,
  deleteUser,
};