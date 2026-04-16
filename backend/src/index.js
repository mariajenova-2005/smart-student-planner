require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const tasksRoutes = require('./routes/tasks');
const notesRoutes = require('./routes/notes');

const app = express();

// Middleware
app.use(cors());
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