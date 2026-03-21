const express = require('express');
const { sql } = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.get('/', async (req, res) => {
  try {
    const tasks = await sql`
      SELECT id, title, description, due_date, priority, is_completed, category, created_at, updated_at
      FROM tasks WHERE user_id = ${req.userId} ORDER BY due_date ASC
    `;
    res.json({ tasks });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

router.post('/', async (req, res) => {
  const { title, description, dueDate, priority, category } = req.body;
  if (!title || !dueDate)
    return res.status(400).json({ error: 'Title and due date are required' });
  const validPriorities = ['low', 'medium', 'high'];
  const validCategories = ['assignment', 'exam', 'lab', 'project', 'other'];
  try {
    const result = await sql`
      INSERT INTO tasks (user_id, title, description, due_date, priority, category)
      VALUES (
        ${req.userId}, ${title.trim()}, ${description?.trim() || ''},
        ${new Date(dueDate).toISOString()},
        ${validPriorities.includes(priority) ? priority : 'medium'},
        ${validCategories.includes(category) ? category : 'other'}
      )
      RETURNING id, title, description, due_date, priority, is_completed, category, created_at
    `;
    res.status(201).json({ task: result[0] });
  } catch (err) {
    console.error('Create task error:', err.message);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

router.put('/:id', async (req, res) => {
  const { title, description, dueDate, priority, category, isCompleted } = req.body;
  const validPriorities = ['low', 'medium', 'high'];
  const validCategories = ['assignment', 'exam', 'lab', 'project', 'other'];
  try {
    const existing = await sql`SELECT id FROM tasks WHERE id = ${req.params.id} AND user_id = ${req.userId}`;
    if (existing.length === 0) return res.status(404).json({ error: 'Task not found' });
    const result = await sql`
      UPDATE tasks SET
        title = COALESCE(${title?.trim()}, title),
        description = COALESCE(${description?.trim()}, description),
        due_date = COALESCE(${dueDate ? new Date(dueDate).toISOString() : null}, due_date),
        priority = COALESCE(${validPriorities.includes(priority) ? priority : null}, priority),
        category = COALESCE(${validCategories.includes(category) ? category : null}, category),
        is_completed = COALESCE(${typeof isCompleted === 'boolean' ? isCompleted : null}, is_completed),
        updated_at = NOW()
      WHERE id = ${req.params.id} AND user_id = ${req.userId}
      RETURNING id, title, description, due_date, priority, is_completed, category, updated_at
    `;
    res.json({ task: result[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update task' });
  }
});

router.patch('/:id/toggle', async (req, res) => {
  try {
    const result = await sql`
      UPDATE tasks SET is_completed = NOT is_completed, updated_at = NOW()
      WHERE id = ${req.params.id} AND user_id = ${req.userId}
      RETURNING id, is_completed
    `;
    if (result.length === 0) return res.status(404).json({ error: 'Task not found' });
    res.json({ task: result[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to toggle task' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const result = await sql`
      DELETE FROM tasks WHERE id = ${req.params.id} AND user_id = ${req.userId} RETURNING id
    `;
    if (result.length === 0) return res.status(404).json({ error: 'Task not found' });
    res.json({ message: 'Task deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

module.exports = router;
