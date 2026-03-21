const express = require('express');
const { sql } = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.get('/', async (req, res) => {
  try {
    const notes = await sql`
      SELECT id, subject, title, content, created_at, updated_at
      FROM notes WHERE user_id = ${req.userId} ORDER BY updated_at DESC
    `;
    res.json({ notes });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch notes' });
  }
});

router.post('/', async (req, res) => {
  const { subject, title, content } = req.body;
  if (!subject || !title || !content)
    return res.status(400).json({ error: 'Subject, title and content are required' });
  try {
    const result = await sql`
      INSERT INTO notes (user_id, subject, title, content)
      VALUES (${req.userId}, ${subject.trim()}, ${title.trim()}, ${content.trim()})
      RETURNING id, subject, title, content, created_at, updated_at
    `;
    res.status(201).json({ note: result[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create note' });
  }
});

router.put('/:id', async (req, res) => {
  const { subject, title, content } = req.body;
  try {
    const result = await sql`
      UPDATE notes SET
        subject = COALESCE(${subject?.trim()}, subject),
        title = COALESCE(${title?.trim()}, title),
        content = COALESCE(${content?.trim()}, content),
        updated_at = NOW()
      WHERE id = ${req.params.id} AND user_id = ${req.userId}
      RETURNING id, subject, title, content, updated_at
    `;
    if (result.length === 0) return res.status(404).json({ error: 'Note not found' });
    res.json({ note: result[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update note' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const result = await sql`
      DELETE FROM notes WHERE id = ${req.params.id} AND user_id = ${req.userId} RETURNING id
    `;
    if (result.length === 0) return res.status(404).json({ error: 'Note not found' });
    res.json({ message: 'Note deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete note' });
  }
});

module.exports = router;
