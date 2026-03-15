const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'linkvault.db');

const db = new Database(DB_PATH);

// Create table if it doesn't exist
db.exec(`
  CREATE TABLE IF NOT EXISTS links (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    code        TEXT    NOT NULL UNIQUE,
    original_url TEXT   NOT NULL,
    clicks      INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
  )
`);

module.exports = db;
