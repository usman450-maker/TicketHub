const { OAuth2Client } = require('google-auth-library');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);


const bcrypt = require("bcrypt");
const generateToken = require("../utils/generateToken");
const sendEmail = require("../utils/sendEmail");

const {
  createUser,
  findUserByEmail,
  findUserById,
  findUserByIdWithPassword,
  updatePassword,
  updateProfile,
  deleteUser,
} = require("../models/userModel");

const {
  saveOTP,
  getOTP,
  deleteOTP,
} = require("../models/passwordResetModel");

// ==========================
// EMAIL TEMPLATE HELPER (TicketHub Branding)
// ==========================
// ==========================
// EMAIL TEMPLATE HELPER (TicketHub Branding - Light Green)
// ==========================
const emailTemplate = (title, content) => `
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; background: #f9fafb; padding: 20px;">
  <div style="background: linear-gradient(135deg, #6B8E7B 0%, #7FA890 100%); padding: 30px; text-align: center; border-radius: 12px 12px 0 0;">
    <h1 style="color: #ffffff; margin: 0; font-size: 32px; letter-spacing: 1px; font-weight: 600;">🎫 TicketHub</h1>
    <p style="color: rgba(255,255,255,0.95); margin: 8px 0 0 0; font-size: 14px;">One app. Every ticket.</p>
  </div>
  <div style="background: #ffffff; padding: 30px; border-radius: 0 0 12px 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
    <h2 style="color: #6B8E7B; margin-top: 0; font-weight: 600;">${title}</h2>
    ${content}
    <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 30px 0 20px 0;">
    <p style="color: #9CA3AF; font-size: 12px; text-align: center; margin: 0;">
      © ${new Date().getFullYear()} TicketHub. All rights reserved.<br>
      <span style="letter-spacing: 2px;">EXCELLENCE IN EVERY ARRIVAL</span>
    </p>
  </div>
</div>
`;

// ==========================
// SEND SIGNUP OTP (NEW)
// ==========================
const sendSignupOtp = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please fill all required fields.",
      });
    }

    // Check if user already exists
    const existingUser = await findUserByEmail(email);

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "Email already registered. Please login.",
      });
    }

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    // Delete old OTP if exists
    await deleteOTP(email.toLowerCase());

    // Save OTP
    await saveOTP(email.toLowerCase(), otp, expiresAt);

    // Send OTP Email
    await sendEmail(
      email,
      "TicketHub Signup Verification Code 🎫",
      emailTemplate(
        `Verify Your Email`,
        `
          <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
            Hello <strong>${name}</strong>,
          </p>
          <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
            Thanks for signing up on <strong>TicketHub</strong>! To complete your registration, please verify your email using the OTP below:
          </p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="display: inline-block; padding: 20px 40px; background: linear-gradient(135deg, #6B8E7B 0%, #7FA890 100%); border-radius: 12px;">
              <h1 style="color: #ffffff; margin: 0; font-size: 42px; letter-spacing: 10px; font-weight: bold;">${otp}</h1>
            </div>
          </div>
          <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 15px; margin: 20px 0; border-radius: 6px;">
            <p style="color: #065F46; margin: 0; font-size: 14px;">
              ⏱️ This OTP is valid for <strong>10 minutes</strong> only.
            </p>
          </div>
          <p style="color: #6B7280; font-size: 14px; line-height: 1.6;">
            If you didn't request this, please ignore this email.
          </p>
        `
      )
    );

    return res.status(200).json({
      success: true,
      message: "OTP sent to your email. Please verify to complete signup.",
    });

  } catch (error) {
    console.log("SEND SIGNUP OTP ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// VERIFY SIGNUP OTP & CREATE ACCOUNT (NEW)
// ==========================
const verifySignupOtp = async (req, res) => {
  try {
    const { name, email, phone, password, otp } = req.body;

    if (!name || !email || !password || !otp) {
      return res.status(400).json({
        success: false,
        message: "All fields are required.",
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // Double check user doesn't exist
    const existingUser = await findUserByEmail(normalizedEmail);

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "Email already registered.",
      });
    }

    // Verify OTP
    const record = await getOTP(normalizedEmail);

    if (!record) {
      return res.status(400).json({
        success: false,
        message: "OTP not found. Please request a new one.",
      });
    }

    if (record.otp.toString().trim() !== otp.toString().trim()) {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP.",
      });
    }

    if (new Date(record.expires_at) < new Date()) {
      return res.status(400).json({
        success: false,
        message: "OTP has expired. Please request a new one.",
      });
    }

    // OTP is valid — Create the user
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await createUser(
      name,
      normalizedEmail,
      phone || null,
      hashedPassword
    );

    // Delete OTP after successful use
    await deleteOTP(normalizedEmail);

    // Generate token
    const token = generateToken(user.id);

    // Send Welcome Email
    try {
      await sendEmail(
        normalizedEmail,
        "Welcome to TicketHub 🎫",
        emailTemplate(
          `Welcome ${name} 👋`,
          `
            <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
              Congratulations! Your <strong>TicketHub</strong> account has been created successfully.
            </p>
            <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
              You can now book tickets for:
            </p>
            <ul style="color: #1A2E22; font-size: 15px; line-height: 1.8;">
              <li>🎬 Movies</li>
              <li>🚌 Buses</li>
              <li>🚆 Trains</li>
              <li>✈️ Flights</li>
              <li>🎤 Events & Concerts</li>
              <li>⚽ Sports Matches</li>
            </ul>
            <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
              Enjoy a seamless booking experience with premium features.
            </p>
            <div style="text-align: center; margin: 30px 0;">
              <span style="display: inline-block; padding: 12px 30px; background: #6B8E7B; color: #ffffff; border-radius: 30px; font-weight: bold;">Start Exploring</span>
            </div>
          `
        )
      );
    } catch (mailError) {
      console.log("WELCOME EMAIL ERROR:", mailError);
    }

    res.status(201).json({
      success: true,
      message: "Account created successfully!",
      token,
      user,
    });

  } catch (error) {
    console.log("VERIFY SIGNUP OTP ERROR:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// RESEND SIGNUP OTP (NEW)
// ==========================
const resendSignupOtp = async (req, res) => {
  try {
    const { name, email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required.",
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists
    const existingUser = await findUserByEmail(normalizedEmail);

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "Email already registered.",
      });
    }

    // Delete old OTP
    await deleteOTP(normalizedEmail);

    // Generate new OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await saveOTP(normalizedEmail, otp, expiresAt);

    await sendEmail(
      normalizedEmail,
      "TicketHub New Signup OTP 🎫",
      emailTemplate(
        `Your New OTP`,
        `
          <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
            Hello <strong>${name || "there"}</strong>,
          </p>
          <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
            Here's your new OTP for TicketHub signup verification:
          </p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="display: inline-block; padding: 20px 40px; background: linear-gradient(135deg, #2D5A3D 0%, #1A3D28 100%); border-radius: 12px;">
              <h1 style="color: #ffffff; margin: 0; font-size: 42px; letter-spacing: 10px; font-weight: bold;">${otp}</h1>
            </div>
          </div>
          <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 15px; margin: 20px 0; border-radius: 6px;">
            <p style="color: #065F46; margin: 0; font-size: 14px;">
              ⏱️ This OTP is valid for <strong>10 minutes</strong> only.
            </p>
          </div>
        `
      )
    );

    res.status(200).json({
      success: true,
      message: "New OTP sent successfully.",
    });

  } catch (error) {
    console.log("RESEND SIGNUP OTP ERROR:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// LOGIN (unchanged)
// ==========================
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please fill all fields.",
      });
    }

    const user = await findUserByEmail(email);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password.",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password.",
      });
    }

    const token = generateToken(user.id);

    res.status(200).json({
      success: true,
      message: "Login Successful",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};



// ==========================
// GOOGLE SIGN-IN (No Firebase)
// ==========================
const googleSignIn = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: "Google ID token is required.",
      });
    }

    // Verify Google ID token
    let payload;
    try {
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });
      payload = ticket.getPayload();
    } catch (verifyError) {
      console.log("Token verification failed:", verifyError.message);
      return res.status(401).json({
        success: false,
        message: "Invalid Google token.",
      });
    }

    const { email, name, sub: googleId, picture } = payload;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email not found in Google account.",
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // Check if user exists
    let user = await findUserByEmail(normalizedEmail);

    if (user) {
      // Existing user → Login
      const token = generateToken(user.id);

      return res.status(200).json({
        success: true,
        message: "Login Successful",
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
        },
      });
    }

    // New user → Create account
    const hashedPassword = await bcrypt.hash(googleId, 10);

    user = await createUser(
      name || 'Google User',
      normalizedEmail,
      null,
      hashedPassword
    );

    const token = generateToken(user.id);

    // Send welcome email
    try {
      await sendEmail(
        normalizedEmail,
        "Welcome to TicketHub 🎫",
        emailTemplate(
          `Welcome ${user.name} 👋`,
          `
            <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
              Your <strong>TicketHub</strong> account has been created successfully using Google Sign-In.
            </p>
            <p style="color: #1A2E22; font-size: 16px; line-height: 1.6;">
              You can now book tickets for movies, buses, trains, flights, events, and more!
            </p>
            <div style="text-align: center; margin: 30px 0;">
              <span style="display: inline-block; padding: 12px 30px; background: #6B8E7B; color: #ffffff; border-radius: 30px; font-weight: 600;">Start Exploring</span>
            </div>
          `
        )
      );
    } catch (mailError) {
      console.log("EMAIL ERROR:", mailError);
    }

    return res.status(201).json({
      success: true,
      message: "Account created successfully",
      token,
      user,
    });

  } catch (error) {
    console.log("GOOGLE SIGN-IN ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// GET PROFILE
// ==========================
const getProfile = async (req, res) => {
  try {
    const user = await findUserById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    res.status(200).json({
      success: true,
      user,
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// CHANGE PASSWORD
// ==========================
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Please fill all fields.",
      });
    }

    const user = await findUserByIdWithPassword(req.user.id);

    const isMatch = await bcrypt.compare(currentPassword, user.password);

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: "Current password is incorrect.",
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await updatePassword(user.email, hashedPassword);

    try {
      await sendEmail(
        user.email,
        "Password Changed - TicketHub 🔐",
        emailTemplate(
          `Password Changed Successfully`,
          `
            <p style="color: #1A2E22; font-size: 16px;">Hello <strong>${user.name}</strong>,</p>
            <p style="color: #1A2E22; font-size: 16px;">Your TicketHub password was changed successfully.</p>
            <div style="background: #FEF3C7; border-left: 4px solid #F59E0B; padding: 15px; margin: 20px 0;">
              <p style="color: #92400E; margin: 0;">⚠️ If this wasn't you, reset your password immediately.</p>
            </div>
          `
        )
      );
    } catch (e) {
      console.log("EMAIL ERROR:", e);
    }

    res.status(200).json({
      success: true,
      message: "Password changed successfully.",
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// UPDATE PROFILE
// ==========================
const updateUserProfile = async (req, res) => {
  try {
    const { name, email, phone } = req.body;

    if (!name || !email) {
      return res.status(400).json({
        success: false,
        message: "Please fill all fields.",
      });
    }

    const currentUser = await findUserById(req.user.id);

    if (!currentUser) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    const emailUser = await findUserByEmail(email);

    if (emailUser && emailUser.id !== req.user.id) {
      return res.status(400).json({
        success: false,
        message: "Email already exists.",
      });
    }

    const updatedUser = await updateProfile(
      req.user.id, name, email, phone || null
    );

    res.status(200).json({
      success: true,
      message: "Profile updated successfully.",
      user: updatedUser,
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==========================
// FORGOT PASSWORD
// ==========================
const forgotPassword = async (req, res) => {
  try {
    const email = req.body.email?.trim().toLowerCase();

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required.",
      });
    }

    const user = await findUserByEmail(email);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await deleteOTP(email);
    await saveOTP(email, otp, expiresAt);

    await sendEmail(
      email,
      "TicketHub Password Reset OTP 🔐",
      emailTemplate(
        `Password Reset Request`,
        `
          <p style="color: #1A2E22; font-size: 16px;">Hello <strong>${user.name}</strong>,</p>
          <p style="color: #1A2E22; font-size: 16px;">We received a request to reset your TicketHub password.</p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="display: inline-block; padding: 20px 40px; background: linear-gradient(135deg, #2D5A3D 0%, #1A3D28 100%); border-radius: 12px;">
              <h1 style="color: #ffffff; margin: 0; font-size: 42px; letter-spacing: 10px;">${otp}</h1>
            </div>
          </div>
          <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 15px; margin: 20px 0;">
            <p style="color: #065F46; margin: 0;">⏱️ Valid for <strong>10 minutes</strong> only.</p>
          </div>
        `
      )
    );

    return res.status(200).json({
      success: true,
      message: "OTP sent successfully.",
    });

  } catch (error) {
    console.log(error);
    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// VERIFY OTP (For Forgot Password)
// ==========================
const verifyOtp = async (req, res) => {
  try {
    const email = req.body.email?.trim().toLowerCase();
    const otp = req.body.otp?.trim();

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP are required.",
      });
    }

    const record = await getOTP(email);

    if (!record) {
      return res.status(400).json({
        success: false,
        message: "OTP not found.",
      });
    }

    if (record.otp.toString().trim() !== otp) {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP.",
      });
    }

    if (new Date(record.expires_at) < new Date()) {
      return res.status(400).json({
        success: false,
        message: "OTP expired.",
      });
    }

    res.status(200).json({
      success: true,
      message: "OTP verified.",
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// RESEND OTP (For Forgot Password)
// ==========================
const resendOtp = async (req, res) => {
  try {
    const email = req.body.email?.trim().toLowerCase();

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required.",
      });
    }

    const user = await findUserByEmail(email);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    await deleteOTP(email);

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await saveOTP(email, otp, expiresAt);

    await sendEmail(
      email,
      "TicketHub New OTP Code 🔐",
      emailTemplate(
        `Your New OTP`,
        `
          <p style="color: #1A2E22; font-size: 16px;">Hello <strong>${user.name}</strong>,</p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="display: inline-block; padding: 20px 40px; background: linear-gradient(135deg, #2D5A3D 0%, #1A3D28 100%); border-radius: 12px;">
              <h1 style="color: #ffffff; margin: 0; font-size: 42px; letter-spacing: 10px;">${otp}</h1>
            </div>
          </div>
          <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 15px; margin: 20px 0;">
            <p style="color: #065F46; margin: 0;">⏱️ Valid for <strong>10 minutes</strong> only.</p>
          </div>
        `
      )
    );

    res.status(200).json({
      success: true,
      message: "OTP sent successfully.",
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// RESET PASSWORD
// ==========================
const resetPassword = async (req, res) => {
  try {
    const email = req.body.email.trim().toLowerCase();
    const newPassword = req.body.newPassword;

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    const updatedUser = await updatePassword(email, hashedPassword);

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    await deleteOTP(email);

    await sendEmail(
      email,
      "TicketHub Password Reset Successful ✅",
      emailTemplate(
        `Password Reset Successful`,
        `
          <p style="color: #1A2E22; font-size: 16px;">Hello <strong>${updatedUser.name}</strong>,</p>
          <p style="color: #1A2E22; font-size: 16px;">Your TicketHub password has been reset successfully.</p>
          <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 15px; margin: 20px 0;">
            <p style="color: #065F46; margin: 0;">✅ You can now login with your new password.</p>
          </div>
        `
      )
    );

    res.status(200).json({
      success: true,
      message: "Password reset successful.",
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};




// ==========================
// DELETE ACCOUNT
// ==========================
const deleteAccount = async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: "Password is required.",
      });
    }

    const user = await findUserByIdWithPassword(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found.",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Password is incorrect.",
      });
    }

    try {
      await sendEmail(
        user.email,
        "TicketHub Account Deleted ❌",
        emailTemplate(
          `Account Deleted`,
          `
            <p style="color: #1A2E22; font-size: 16px;">Goodbye <strong>${user.name}</strong>,</p>
            <p style="color: #1A2E22; font-size: 16px;">Your TicketHub account has been permanently deleted.</p>
          `
        )
      );
    } catch (e) {
      console.log("EMAIL ERROR:", e);
    }

    await deleteOTP(user.email);
    await deleteUser(user.id);

    res.status(200).json({
      success: true,
      message: "Account deleted successfully.",
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// ==========================
// EXPORTS
// ==========================
module.exports = {
  sendSignupOtp,       // NEW
  verifySignupOtp,     // NEW
  resendSignupOtp,     // NEW
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
};