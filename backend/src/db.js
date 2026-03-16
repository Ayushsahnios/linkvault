const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DB_CONNECTION_STRING,
  ssl: { rejectUnauthorized: false },
});

const initDb = async () => {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS links (
      id          SERIAL PRIMARY KEY,
      code        TEXT    NOT NULL UNIQUE,
      original_url TEXT   NOT NULL,
      clicks      INTEGER NOT NULL DEFAULT 0,
      created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
  console.log('Database ready');
};

module.exports = { pool, initDb };
