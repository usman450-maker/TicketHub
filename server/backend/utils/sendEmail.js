const nodemailer = require("nodemailer");

const sendEmail = async (email, subject, message) => {
  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    await transporter.sendMail({
      from: `"TicketHub 🎫" <${process.env.EMAIL_USER}>`,
      to: email,
      subject,
      html: message,
    });

    console.log("✅ Email Sent Successfully");
  } catch (error) {
    console.log("❌ Email Error");
    console.log(error);
  }
};

module.exports = sendEmail;