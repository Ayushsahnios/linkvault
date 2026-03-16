const express = require('express');
const { nanoid } = require('nanoid');
const { pool } = require('../db');

const router = express.Router();

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

// POST /shorten
router.post('/shorten', async (req, res) => {
  const { url } = req.body;

  if (!url) {
    return res.status(400).json({ error: 'url is required' });
  }

  try {
    new URL(url);
  } catch {
    return res.status(400).json({ error: 'Invalid URL format' });
  }

  try {
    const code = nanoid(7);
    await pool.query(
      'INSERT INTO links (code, original_url) VALUES ($1, $2)',
      [code, url]
    );
    return res.status(201).json({
      code,
      shortUrl: `${BASE_URL}/${code}`,
      originalUrl: url,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /stats/:code
router.get('/stats/:code', async (req, res) => {
  const { code } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM links WHERE code = $1',
      [code]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Short link not found' });
    }

    const link = result.rows[0];

    return res.json({
      code: link.code,
      originalUrl: link.original_url,
      clicks: link.clicks,
      createdAt: link.created_at,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /:code
router.get('/:code', async (req, res) => {
  const { code } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM links WHERE code = $1',
      [code]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Short link not found' });
    }

    const link = result.rows[0];

    await pool.query(
      'UPDATE links SET clicks = clicks + 1 WHERE code = $1',
      [code]
    );

    return res.redirect(302, link.original_url);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});



module.exports = router;
