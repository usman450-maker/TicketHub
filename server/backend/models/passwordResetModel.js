const pool = require("../config/db");

// ==========================
// Save OTP
// ==========================
const saveOTP = async (email, otp, expiresAt) => {

  email = email.trim().toLowerCase();

  await pool.query(
    `
    INSERT INTO password_resets(email, otp, expires_at)
    VALUES($1,$2,$3)
    `,
    [email, otp, expiresAt]
  );
};

// ==========================
// Get Latest OTP
// ==========================
const getOTP = async (email) => {

  email = email.trim().toLowerCase();

  const result = await pool.query(
    `
    SELECT *
    FROM password_resets
    WHERE LOWER(TRIM(email)) = $1
    ORDER BY created_at DESC
    LIMIT 1
    `,
    [email]
  );

  return result.rows[0];
};

// ==========================
// Delete OTP
// ==========================
const deleteOTP = async (email) => {

  email = email.trim().toLowerCase();

  await pool.query(
    `
    DELETE FROM password_resets
    WHERE LOWER(TRIM(email)) = $1
    `,
    [email]
  );
};

module.exports = {
  saveOTP,
  getOTP,
  deleteOTP,
};