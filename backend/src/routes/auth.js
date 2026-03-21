const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { sql } = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password)
    return res.status(400).json({ error: 'Name, email and password are required' });
  if (password.length < 6)
    return res.status(400).json({ error: 'Password must be at least 6 characters' });
  if (!email.includes('@'))
    return res.status(400).json({ error: 'Invalid email address' });
  try {
    const existing = await sql`SELECT id FROM users WHERE email = ${email.toLowerCase().trim()}`;
    if (existing.length > 0)
      return res.status(409).json({ error: 'Email already registered. Please login.' });
    const passwordHash = await bcrypt.hash(password, 12);
    const result = await sql`
      INSERT INTO users (name, email, password_hash)
      VALUES (${name.trim()}, ${email.toLowerCase().trim()}, ${passwordHash})
      RETURNING id, name, email
    `;
    const user = result[0];
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.status(201).json({ token, user: { id: user.id, name: user.name, email: user.email } });
  } catch (err) {
    console.error('Register error:', err.message);
    res.status(500).json({ error: 'Registration failed. Please try again.' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: 'Email and password are required' });
  try {
    const result = await sql`
      SELECT id, name, email, password_hash FROM users
      WHERE email = ${email.toLowerCase().trim()}
    `;
    if (result.length === 0)
      return res.status(401).json({ error: 'No account found with this email.' });
    const user = result[0];
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid)
      return res.status(401).json({ error: 'Incorrect password.' });
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ error: 'Login failed. Please try again.' });
  }
});

router.get('/me', authMiddleware, async (req, res) => {
  try {
    const result = await sql`SELECT id, name, email FROM users WHERE id = ${req.userId}`;
    if (result.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json({ user: result[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to get user' });
  }
});

router.put('/profile', authMiddleware, async (req, res) => {
  const { name } = req.body;
  if (!name || name.trim().length === 0)
    return res.status(400).json({ error: 'Name is required' });
  try {
    const result = await sql`
      UPDATE users SET name = ${name.trim()}, updated_at = NOW()
      WHERE id = ${req.userId} RETURNING id, name, email
    `;
    res.json({ user: result[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
