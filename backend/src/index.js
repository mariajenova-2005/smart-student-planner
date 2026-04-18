require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const tasksRoutes = require('./routes/tasks');
const notesRoutes = require('./routes/notes');

const app = express();

// Middleware

const allowedOrigins = [
  'https://smart-student-planner-ruddy.vercel.app',
  'http://localhost:3000',
  'http://localhost:5000',
  'http://10.0.2.2:3000', // Android emulator
];

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, Postman)
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    // Also allow any vercel.app subdomain (for preview deployments)
    if (/\.vercel\.app$/.test(origin)) return callback(null, true);
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true
}));
app.use(express.json());

// ✅ Root route (fixes your Render "/" issue)
app.get('/', (req, res) => {
  res.send('🚀 Student Planner Pro API is live');
});

// ✅ Health check route
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Student Planner Pro API is running'
  });
});

// ✅ API routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', tasksRoutes);
app.use('/api/notes', notesRoutes);

// ❌ 404 handler (keep this LAST)
app.use((req, res) => {
  res.status(404).json({
    error: `Route ${req.method} ${req.path} not found`
  });
});

// ❌ Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err.stack);
  res.status(500).json({
    error: 'Internal server error'
  });
});

// ✅ Use Render's PORT
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`\n🚀 Student Planner Pro API running on port ${PORT}`);
  console.log(`🌐 Root: /`);
  console.log(`❤️ Health: /health\n`);
});

module.exports = app;