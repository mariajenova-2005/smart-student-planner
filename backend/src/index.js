require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { neon } = require('@neondatabase/serverless');

const authRoutes = require('./routes/auth');
const tasksRoutes = require('./routes/tasks');
const notesRoutes = require('./routes/notes');

// Auto-run migrations on startup so tables always exist
async function runMigrations() {
  try {
    const sql = neon(process.env.DATABASE_URL);
    await sql`CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    )`;
    await sql`CREATE TABLE IF NOT EXISTS tasks (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      title VARCHAR(500) NOT NULL,
      description TEXT DEFAULT '',
      due_date TIMESTAMP WITH TIME ZONE NOT NULL,
      priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low','medium','high')),
      is_completed BOOLEAN DEFAULT FALSE,
      category VARCHAR(50) DEFAULT 'other' CHECK (category IN ('assignment','exam','lab','project','other')),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    )`;
    await sql`CREATE TABLE IF NOT EXISTS notes (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      subject VARCHAR(255) NOT NULL,
      title VARCHAR(500) NOT NULL,
      content TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    )`;
    await sql`CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_notes_user_id ON notes(user_id)`;
    console.log('✅ Database tables ready');
  } catch (err) {
    console.error('❌ Migration error:', err.message);
  }
}

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

// Run migrations first, then start server
runMigrations().then(() => {
  app.listen(PORT, () => {
    console.log(`\n🚀 Student Planner Pro API running on port ${PORT}`);
    console.log(`🌐 Root: /`);
    console.log(`❤️  Health: /health\n`);
  });
});

module.exports = app;