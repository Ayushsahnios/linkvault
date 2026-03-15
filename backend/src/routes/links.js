const express = require('express');
const { nanoid } = require('nanoid');
const db = require('../db');

const router = express.Router();

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

// POST /shorten
// Body: { url: "https://example.com/very-long-url" }
// Returns: { code, shortUrl, originalUrl }
router.post('/shorten', (req, res) => {
  const { url } = req.body;

  if (!url) {
    return res.status(400).json({ error: 'url is required' });
  }

  // Basic URL validation
  try {
    new URL(url);
  } catch {
    return res.status(400).json({ error: 'Invalid URL format' });
  }

  const code = nanoid(7); // e.g. "V1StGXR"

  const insert = db.prepare(
    'INSERT INTO links (code, original_url) VALUES (?, ?)'
  );
  insert.run(code, url);

  return res.status(201).json({
    code,
    shortUrl: `${BASE_URL}/${code}`,
    originalUrl: url,
  });
});

// GET /:code
// Redirects to the original URL and increments click count
router.get('/:code', (req, res) => {
  const { code } = req.params;

  const link = db.prepare('SELECT * FROM links WHERE code = ?').get(code);

  if (!link) {
    return res.status(404).json({ error: 'Short link not found' });
  }

  db.prepare('UPDATE links SET clicks = clicks + 1 WHERE code = ?').run(code);

  return res.redirect(302, link.original_url);
});

// GET /stats/:code
// Returns { code, originalUrl, clicks, createdAt }
router.get('/stats/:code', (req, res) => {
  const { code } = req.params;

  const link = db.prepare('SELECT * FROM links WHERE code = ?').get(code);

  if (!link) {
    return res.status(404).json({ error: 'Short link not found' });
  }

  return res.json({
    code: link.code,
    originalUrl: link.original_url,
    clicks: link.clicks,
    createdAt: link.created_at,
  });
});

module.exports = router;
