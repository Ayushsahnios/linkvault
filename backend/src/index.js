require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDb } = require('./db');
const linksRouter = require('./routes/links');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'linkvault' });
});

app.use('/', linksRouter);

const start = async () => {
  await initDb();
  app.listen(PORT, () => {
    console.log(`LinkVault running on http://localhost:${PORT}`);
  });
};

if (require.main === module) {
  start();
}

module.exports = app;
