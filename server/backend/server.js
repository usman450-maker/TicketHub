require("dotenv").config();

const express = require("express");
const cors = require("cors");
const pool = require("./config/db");

// Routes
const authRoutes = require("./routes/authRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Test Route
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "TicketHub Backend is Running 🎫",
  });
});

// Auth Routes
app.use("/api/auth", authRoutes);

// Database Connection
pool.connect()
  .then(() => {
    console.log("✅ PostgreSQL Connected Successfully");
  })
  .catch((err) => {
    console.error("❌ PostgreSQL Connection Failed");
    console.error(err.message);
  });

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 TicketHub Server running on port ${PORT}`);
});