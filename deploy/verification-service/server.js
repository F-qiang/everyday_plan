const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 3000);
const apiPrefix = process.env.API_PREFIX || '/api/auth';
const codeExpiresMs = Number(process.env.CODE_EXPIRES_MS || 5 * 60 * 1000);
const resendCooldownMs = Number(process.env.RESEND_COOLDOWN_MS || 60 * 1000);

const requiredEnv = [
  'SMTP_HOST',
  'SMTP_PORT',
  'SMTP_USER',
  'SMTP_PASS',
  'SMTP_FROM'
];

for (const key of requiredEnv) {
  if (!process.env[key]) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
}

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT),
  secure: String(process.env.SMTP_SECURE || 'true').toLowerCase() === 'true',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  }
});

const verificationStore = new Map();

app.use(cors());
app.use(express.json({ limit: '32kb' }));

function now() {
  return Date.now();
}

function cleanupExpiredCodes() {
  const current = now();
  for (const [email, record] of verificationStore.entries()) {
    if (!record || record.expiresAt <= current) {
      verificationStore.delete(email);
    }
  }
}

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function validateEmail(email) {
  return /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email);
}

function buildMailHtml(code) {
  return `
    <html>
      <body style="font-family: Arial, sans-serif; background: #f5f7fb; padding: 24px; color: #1f2937;">
        <div style="max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 16px; padding: 32px; border: 1px solid #e5e7eb;">
          <h2 style="margin-top: 0; color: #2563eb;">Everyday Plan</h2>
          <p>您好，</p>
          <p>您正在登录 Everyday Plan，验证码如下：</p>
          <div style="margin: 24px 0; padding: 16px; text-align: center; background: #eff6ff; border-radius: 12px; font-size: 28px; font-weight: 700; letter-spacing: 8px; color: #1d4ed8;">
            ${code}
          </div>
          <p>验证码 5 分钟内有效，请尽快使用。</p>
          <p style="color: #6b7280; font-size: 12px; margin-top: 24px;">如果这不是您的操作，请忽略此邮件。</p>
        </div>
      </body>
    </html>
  `;
}

app.get('/health', (req, res) => {
  res.json({ success: true, message: 'ok' });
});

app.post(`${apiPrefix}/send-code`, async (req, res) => {
  cleanupExpiredCodes();

  const email = normalizeEmail(req.body && req.body.email);
  if (!validateEmail(email)) {
    return res.status(400).json({ success: false, message: '邮箱格式不正确' });
  }

  const existing = verificationStore.get(email);
  const current = now();
  if (existing && existing.lastSentAt && current - existing.lastSentAt < resendCooldownMs) {
    const remainingSeconds = Math.ceil((resendCooldownMs - (current - existing.lastSentAt)) / 1000);
    return res.status(429).json({ success: false, message: `请求过于频繁，请 ${remainingSeconds} 秒后再试` });
  }

  const code = generateCode();
  const expiresAt = current + codeExpiresMs;

  try {
    await transporter.sendMail({
      from: process.env.SMTP_FROM,
      to: email,
      subject: 'Everyday Plan - 您的登录验证码',
      html: buildMailHtml(code)
    });

    verificationStore.set(email, {
      code,
      expiresAt,
      lastSentAt: current
    });

    return res.json({ success: true, message: '验证码已发送，请查收邮件' });
  } catch (error) {
    console.error('send-code failed:', error);
    return res.status(500).json({ success: false, message: '验证码发送失败，请稍后重试' });
  }
});

app.post(`${apiPrefix}/verify-code`, (req, res) => {
  cleanupExpiredCodes();

  const email = normalizeEmail(req.body && req.body.email);
  const code = String((req.body && req.body.code) || '').trim();

  if (!validateEmail(email)) {
    return res.status(400).json({ success: false, message: '邮箱格式不正确' });
  }

  if (!/^\d{6}$/.test(code)) {
    return res.status(400).json({ success: false, message: '验证码格式不正确' });
  }

  const record = verificationStore.get(email);
  if (!record) {
    return res.status(400).json({ success: false, message: '验证码错误或已过期' });
  }

  if (record.expiresAt <= now()) {
    verificationStore.delete(email);
    return res.status(400).json({ success: false, message: '验证码错误或已过期' });
  }

  if (record.code !== code) {
    return res.status(400).json({ success: false, message: '验证码错误或已过期' });
  }

  verificationStore.delete(email);
  return res.json({ success: true, message: '验证成功' });
});

app.listen(port, async () => {
  try {
    await transporter.verify();
    console.log(`Verification service is running at http://localhost:${port}${apiPrefix}`);
  } catch (error) {
    console.error('SMTP verify failed:', error);
    process.exit(1);
  }
});
